import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that guards against calling [notifyListeners]
/// after the object has been disposed. This prevents the common
/// "used after being disposed" exceptions that can happen when
/// asynchronous work completes after a provider is disposed.
class SafeChangeNotifier extends ChangeNotifier {
  bool _isDisposed = false;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
