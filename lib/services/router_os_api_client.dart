import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class RouterOsApiException implements Exception {
  final String message;
  final Map<String, String> details;

  RouterOsApiException(this.message, {Map<String, String>? details})
    : details = details ?? const {};

  @override
  String toString() => message;
}

class RouterOsApiClient {
  RouterOsApiClient({
    required this.host,
    this.port = 8728,
    this.useSsl = false,
    this.timeout = const Duration(seconds: 8),
    this.allowSelfSigned = true,
    this.verbose = false,
  });

  final String host;
  final int port;
  final bool useSsl;
  final Duration timeout;
  final bool allowSelfSigned;
  final bool verbose;

  Socket? _socket;
  StreamSubscription<List<int>>? _subscription;
  final Queue<int> _incomingBuffer = Queue<int>();
  Completer<void>? _bufferNotifier;
  Object? _lastSocketError;
  bool _isSocketClosed = false;
  bool _isLoggedIn = false;
  Future<void> _pending = Future.value();

  bool get isConnected => _socket != null;

  Future<void> connect() async {
    if (_socket != null) {
      return;
    }

    try {
      if (useSsl) {
        _socket = await SecureSocket.connect(
          host,
          port,
          timeout: timeout,
          onBadCertificate: allowSelfSigned ? (_) => true : null,
        );
      } else {
        _socket = await Socket.connect(host, port, timeout: timeout);
      }
      _socket?.setOption(SocketOption.tcpNoDelay, true);
      _resetSocketState();
      if (verbose) {
        print('Connected to $host:$port (${useSsl ? 'ssl' : 'tcp'})');
      }
    } on SocketException catch (error) {
      await close();
      throw RouterOsApiException(
        'Tidak dapat terhubung ke $host:$port (${error.message})',
      );
    }
  }

  Future<bool> login({required String username, required String password}) {
    return _synchronized(() async {
      await _ensureConnection();

      try {
        final firstAttempt = await _sendForDone([
          '/login',
          '=name=$username',
          '=password=$password',
        ]);

        if (firstAttempt.doneFields.containsKey('ret')) {
          final challenge = firstAttempt.doneFields['ret']!;
          final response = _buildChallengeResponse(password, challenge);

          final secondAttempt = await _sendForDone([
            '/login',
            '=name=$username',
            '=response=$response',
          ]);

          _isLoggedIn = !secondAttempt.hasTrap;
          return _isLoggedIn;
        }

        _isLoggedIn = !firstAttempt.hasTrap;
        return _isLoggedIn;
      } on RouterOsApiException catch (error) {
        if (verbose) {
          debugPrint('RouterOS login error: ${error.message}');
        }
        return false;
      }
    });
  }

  Future<List<Map<String, String>>> runCommand(
    String command, {
    Map<String, String>? parameters,
  }) {
    return _synchronized(() async {
      await _ensureConnection();

      if (!_isLoggedIn) {
        throw RouterOsApiException('Belum login ke RouterOS');
      }

      final sentence = <String>[command];
      parameters?.forEach((key, value) {
        sentence.add('=$key=$value');
      });

      final result = await _sendForDone(sentence, collectReplies: true);
      return result.replies;
    });
  }

  Future<void> close() async {
    try {
      await _subscription?.cancel();
    } catch (_) {}
    _subscription = null;

    try {
      await _socket?.close();
    } catch (_) {}

    _socket = null;
    _isLoggedIn = false;
    _incomingBuffer.clear();
    _bufferNotifier?.complete();
    _bufferNotifier = null;
    _lastSocketError = null;
    _isSocketClosed = false;
  }

  Future<_RouterOsCommandResult> _sendForDone(
    List<String> sentence, {
    bool collectReplies = false,
  }) async {
    await _writeSentence(sentence);

    final replies = <Map<String, String>>[];

    while (true) {
      final words = await _readSentence();
      if (words.isEmpty) {
        continue;
      }

      final replyType = words.first;
      final fields = _wordsToMap(words.skip(1));

      if (replyType == '!re') {
        if (collectReplies) {
          replies.add(fields);
        }
      } else if (replyType == '!done') {
        return _RouterOsCommandResult(
          replies: replies,
          doneFields: fields,
          hasTrap: false,
        );
      } else if (replyType == '!trap') {
        throw RouterOsApiException(
          fields['message'] ?? 'RouterOS trap error',
          details: fields,
        );
      } else if (replyType == '!fatal') {
        throw RouterOsApiException(
          fields['message'] ?? 'RouterOS fatal error',
          details: fields,
        );
      } else if (replyType == '!error') {
        throw RouterOsApiException(
          fields['message'] ?? 'RouterOS error',
          details: fields,
        );
      }
    }
  }

  Future<void> _ensureConnection() async {
    if (_socket == null) {
      await connect();
    }
    if (_socket != null && _subscription == null) {
      _resetSocketState();
    }
  }

  Future<void> _writeSentence(List<String> words) async {
    final socket = _socket;
    if (socket == null) {
      throw RouterOsApiException('Koneksi ke RouterOS belum tersedia');
    }

    for (final word in words) {
      final data = utf8.encode(word);
      final lengthBytes = _encodeLength(data.length);
      socket.add([...lengthBytes, ...data]);
    }

    socket.add([0]);
    await socket.flush();
  }

  Future<List<String>> _readSentence() async {
    final words = <String>[];

    while (true) {
      final word = await _readWord();
      if (word == null) {
        break;
      }
      words.add(word);
    }

    return words;
  }

  Future<String?> _readWord() async {
    final length = await _readLength();
    if (length == 0) {
      return null;
    }

    final bytes = await _readBytes(length);
    return utf8.decode(bytes);
  }

  Future<int> _readLength() async {
    final firstByte = await _readByte();

    if (firstByte < 0x80) {
      return firstByte;
    } else if ((firstByte & 0xC0) == 0x80) {
      final second = await _readByte();
      return ((firstByte & 0x3F) << 8) + second;
    } else if ((firstByte & 0xE0) == 0xC0) {
      final second = await _readByte();
      final third = await _readByte();
      return ((firstByte & 0x1F) << 16) + (second << 8) + third;
    } else if ((firstByte & 0xF0) == 0xE0) {
      final second = await _readByte();
      final third = await _readByte();
      final fourth = await _readByte();
      return ((firstByte & 0x0F) << 24) +
          (second << 16) +
          (third << 8) +
          fourth;
    } else if (firstByte == 0xF0) {
      final b2 = await _readByte();
      final b3 = await _readByte();
      final b4 = await _readByte();
      final b5 = await _readByte();
      return (b2 << 24) + (b3 << 16) + (b4 << 8) + b5;
    } else {
      throw RouterOsApiException('Format paket RouterOS tidak dikenal');
    }
  }

  Future<List<int>> _readBytes(int length) async {
    final bytes = <int>[];
    for (var i = 0; i < length; i++) {
      bytes.add(await _readByte());
    }
    return bytes;
  }

  Future<int> _readByte() async {
    while (true) {
      if (_incomingBuffer.isNotEmpty) {
        return _incomingBuffer.removeFirst();
      }

      if (_lastSocketError != null) {
        final error = _lastSocketError!;
        _lastSocketError = null;
        throw RouterOsApiException('RouterOS menutup koneksi: $error');
      }

      if (_isSocketClosed) {
        throw RouterOsApiException('RouterOS menutup koneksi');
      }

      _bufferNotifier ??= Completer<void>();
      await _bufferNotifier!.future;
      _bufferNotifier = null;
    }
  }

  List<int> _encodeLength(int length) {
    if (length < 0x80) {
      return [length];
    } else if (length < 0x4000) {
      length |= 0x8000;
      return [(length >> 8) & 0xFF, length & 0xFF];
    } else if (length < 0x200000) {
      length |= 0xC00000;
      return [(length >> 16) & 0xFF, (length >> 8) & 0xFF, length & 0xFF];
    } else if (length < 0x10000000) {
      length |= 0xE0000000;
      return [
        (length >> 24) & 0xFF,
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    } else {
      return [
        0xF0,
        (length >> 24) & 0xFF,
        (length >> 16) & 0xFF,
        (length >> 8) & 0xFF,
        length & 0xFF,
      ];
    }
  }

  Map<String, String> _wordsToMap(Iterable<String> words) {
    final result = <String, String>{};

    for (final word in words) {
      if (word.startsWith('=')) {
        final parts = word.substring(1).split('=');
        if (parts.length >= 2) {
          final key = parts.first;
          final value = parts.sublist(1).join('=');
          result[key] = value;
        }
      } else if (word.startsWith('.')) {
        final parts = word.substring(1).split('=');
        if (parts.length >= 2) {
          final key = '.${parts.first}';
          final value = parts.sublist(1).join('=');
          result[key] = value;
        }
      }
    }

    return result;
  }

  String _buildChallengeResponse(String password, String challengeHex) {
    final challengeBytes = _hexToBytes(challengeHex);

    final passwordBytes = utf8.encode(password);
    final data = <int>[0];
    data
      ..addAll(passwordBytes)
      ..addAll(challengeBytes);

    final hash = md5.convert(data).bytes;
    return '00${_bytesToHex(hash)}';
  }

  List<int> _hexToBytes(String hex) {
    final sanitized = hex.trim();
    final result = <int>[];

    for (var i = 0; i < sanitized.length; i += 2) {
      final byteString = sanitized.substring(i, i + 2);
      final value = int.parse(byteString, radix: 16);
      result.add(value);
    }

    return result;
  }

  String _bytesToHex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  void _resetSocketState() {
    _subscription?.cancel();
    _incomingBuffer.clear();
    _lastSocketError = null;
    _isSocketClosed = false;
    _notifyWaiting();

    final socket = _socket;
    if (socket == null) {
      return;
    }

    _subscription = socket.listen(
      (chunk) {
        if (chunk.isEmpty) {
          return;
        }
        _incomingBuffer.addAll(chunk);
        _notifyWaiting();
      },
      onError: (error) {
        _lastSocketError = error;
        _isSocketClosed = true;
        _notifyWaiting();
      },
      onDone: () {
        _isSocketClosed = true;
        _notifyWaiting();
      },
      cancelOnError: true,
    );
  }

  void _notifyWaiting() {
    final notifier = _bufferNotifier;
    if (notifier != null && !notifier.isCompleted) {
      notifier.complete();
    }
  }

  Future<T> _synchronized<T>(Future<T> Function() action) {
    final task = _pending.then((_) => action());
    _pending = task.whenComplete(() {});
    return task;
  }
}

class _RouterOsCommandResult {
  _RouterOsCommandResult({
    required this.replies,
    required this.doneFields,
    required this.hasTrap,
  });

  final List<Map<String, String>> replies;
  final Map<String, String> doneFields;
  final bool hasTrap;
}
