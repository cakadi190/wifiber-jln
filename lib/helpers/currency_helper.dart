/// Helper class untuk memformat mata uang dengan format Indonesia
///
/// Class ini menyediakan berbagai metode untuk memformat angka menjadi
/// format mata uang Rupiah Indonesia dengan berbagai variasi tampilan,
/// termasuk konversi ke terbilang dalam bahasa Indonesia.
class CurrencyHelper {
  /// Format mata uang dengan format Indonesia (Rp)
  ///
  /// [value] - Nilai mata uang yang akan di format
  /// [includeDecimals] - Apakah ingin menampilkan desimal (default: false)
  /// [decimalPlaces] - Jumlah tempat desimal (default: 0)
  ///
  /// Returns: [String] mata uang yang sudah di format dengan format Indonesia
  ///
  /// Contoh:
  /// ```dart
  /// String formatted1 = CurrencyHelper.formatCurrency(100000);
  /// print(formatted1); // Output: Rp100.000
  ///
  /// String formatted2 = CurrencyHelper.formatCurrency(100000.50, includeDecimals: true, decimalPlaces: 2);
  /// print(formatted2); // Output: Rp100.000,50
  /// ```
  static String formatCurrency(
      num value, {
        bool includeDecimals = false,
        int decimalPlaces = 0,
      }) {
    if (value.isNaN || value.isInfinite) {
      return 'Rp0';
    }

    String formattedValue = _formatNumber(value, includeDecimals, decimalPlaces);
    return 'Rp$formattedValue';
  }

  /// Format mata uang tanpa prefix "Rp"
  ///
  /// [value] - Nilai mata uang yang akan di format
  /// [includeDecimals] - Apakah ingin menampilkan desimal (default: false)
  /// [decimalPlaces] - Jumlah tempat desimal (default: 0)
  ///
  /// Returns: [String] mata uang yang sudah di format tanpa prefix "Rp"
  ///
  /// Contoh:
  /// ```dart
  /// String formatted = CurrencyHelper.formatCurrencyWithoutRp(100000);
  /// print(formatted); // Output: 100.000
  /// ```
  static String formatCurrencyWithoutRp(
      num value, {
        bool includeDecimals = false,
        int decimalPlaces = 0,
      }) {
    if (value.isNaN || value.isInfinite) {
      return '0';
    }

    return _formatNumber(value, includeDecimals, decimalPlaces);
  }

  /// Format mata uang dalam bentuk kompak (K, M, B, T)
  ///
  /// [value] - Nilai mata uang yang akan di format
  /// [decimalPlaces] - Jumlah tempat desimal untuk format kompak (default: 1)
  ///
  /// Returns: [String] mata uang yang sudah di format dalam bentuk kompak
  ///
  /// Contoh:
  /// ```dart
  /// String compact1 = CurrencyHelper.compactFormatCurrency(1500000);
  /// print(compact1); // Output: Rp1,5 Jt
  ///
  /// String compact2 = CurrencyHelper.compactFormatCurrency(2500000000);
  /// print(compact2); // Output: Rp2,5 M
  /// ```
  static String compactFormatCurrency(num value, {int decimalPlaces = 1}) {
    if (value.isNaN || value.isInfinite) {
      return 'Rp0';
    }

    String compactValue = _formatCompactNumber(value, decimalPlaces);
    return 'Rp$compactValue';
  }

  /// Format mata uang dalam bentuk kompak tanpa prefix "Rp"
  ///
  /// [value] - Nilai mata uang yang akan di format
  /// [decimalPlaces] - Jumlah tempat desimal untuk format kompak (default: 1)
  ///
  /// Returns: [String] mata uang yang sudah di format dalam bentuk kompak tanpa prefix "Rp"
  ///
  /// Contoh:
  /// ```dart
  /// String compact = CurrencyHelper.compactFormatCurrencyWithoutRp(1500000);
  /// print(compact); // Output: 1,5 Jt
  /// ```
  static String compactFormatCurrencyWithoutRp(num value, {int decimalPlaces = 1}) {
    if (value.isNaN || value.isInfinite) {
      return '0';
    }

    return _formatCompactNumber(value, decimalPlaces);
  }

  /// Parse string mata uang menjadi angka
  ///
  /// [currencyString] - String mata uang yang akan di parse
  ///
  /// Returns: [double] nilai angka dari string mata uang
  ///
  /// Contoh:
  /// ```dart
  /// double value = CurrencyHelper.parseCurrency('Rp100.000');
  /// print(value); // Output: 100000.0
  /// ```
  static double parseCurrency(String currencyString) {
    if (currencyString.isEmpty) return 0.0;

    String cleanString = currencyString
        .replaceAll('Rp', '')
        .replaceAll(' ', '')
        .trim();

    cleanString = cleanString.replaceAll('.', '').replaceAll(',', '.');

    return double.tryParse(cleanString) ?? 0.0;
  }

  /// Validasi apakah string adalah format mata uang yang valid
  ///
  /// [currencyString] - String yang akan divalidasi
  ///
  /// Returns: [bool] true jika format valid, false jika tidak
  ///
  /// Contoh:
  /// ```dart
  /// bool isValid = CurrencyHelper.isValidCurrencyFormat('Rp100.000');
  /// print(isValid); // Output: true
  /// ```
  static bool isValidCurrencyFormat(String currencyString) {
    if (currencyString.isEmpty) return false;

    RegExp currencyRegex = RegExp(r'^Rp\s\d{1,3}(\.\d{3})*(,\d+)?$');
    return currencyRegex.hasMatch(currencyString);
  }

  /// Konversi mata uang dari string ke format yang diinginkan
  ///
  /// [currencyString] - String mata uang input
  /// [targetFormat] - Format target ('standard', 'compact', 'withoutRp')
  ///
  /// Returns: [String] mata uang dalam format yang diinginkan
  ///
  /// Contoh:
  /// ```dart
  /// String converted = CurrencyHelper.convertCurrencyFormat('Rp1.500.000', 'compact');
  /// print(converted); // Output: Rp1,5 Jt
  /// ```
  static String convertCurrencyFormat(String currencyString, String targetFormat) {
    double value = parseCurrency(currencyString);

    switch (targetFormat.toLowerCase()) {
      case 'compact':
        return compactFormatCurrency(value);
      case 'withoutrp':
        return formatCurrencyWithoutRp(value);
      case 'standard':
      default:
        return formatCurrency(value);
    }
  }

  /// Konversi angka menjadi terbilang dalam bahasa Indonesia
  ///
  /// [value] - Nilai angka yang akan diubah menjadi terbilang
  /// [includeRupiah] - Apakah ingin menambahkan kata "rupiah" di akhir (default: false)
  ///
  /// Returns: [String] angka dalam bentuk terbilang bahasa Indonesia
  ///
  /// Contoh:
  /// ```dart
  /// String terbilang1 = CurrencyHelper.numberToWords(12345);
  /// print(terbilang1); // Output: dua belas ribu tiga ratus empat puluh lima
  ///
  /// String terbilang2 = CurrencyHelper.numberToWords(12345, includeRupiah: true);
  /// print(terbilang2); // Output: dua belas ribu tiga ratus empat puluh lima rupiah
  /// ```
  static String numberToWords(num value, {bool includeRupiah = false}) {
    if (value.isNaN || value.isInfinite) {
      return includeRupiah ? 'nol rupiah' : 'nol';
    }

    int intValue = value.abs().round();

    if (intValue == 0) {
      return includeRupiah ? 'nol rupiah' : 'nol';
    }

    String result = _convertToWords(intValue);

    if (value < 0) {
      result = 'minus $result';
    }

    if (includeRupiah) {
      result += ' rupiah';
    }

    return result;
  }

  /// Konversi mata uang menjadi terbilang dengan prefix "Rp" dan suffix "rupiah"
  ///
  /// [value] - Nilai mata uang yang akan diubah menjadi terbilang
  ///
  /// Returns: [String] mata uang dalam bentuk terbilang lengkap
  ///
  /// Contoh:
  /// ```dart
  /// String terbilang = CurrencyHelper.currencyToWords(12345);
  /// print(terbilang); // Output: dua belas ribu tiga ratus empat puluh lima rupiah
  /// ```
  static String currencyToWords(num value) {
    return numberToWords(value, includeRupiah: true);
  }

  /// Validasi apakah string terbilang adalah format yang valid
  ///
  /// [wordsString] - String terbilang yang akan divalidasi
  ///
  /// Returns: [bool] true jika format valid, false jika tidak
  ///
  /// Contoh:
  /// ```dart
  /// bool isValid = CurrencyHelper.isValidWordsFormat('dua ribu lima ratus rupiah');
  /// print(isValid); // Output: true
  /// ```
  static bool isValidWordsFormat(String wordsString) {
    if (wordsString.isEmpty) return false;

    List<String> validWords = [
      'nol', 'satu', 'dua', 'tiga', 'empat', 'lima', 'enam', 'tujuh', 'delapan', 'sembilan',
      'sepuluh', 'sebelas', 'belas', 'puluh', 'seratus', 'ratus', 'seribu', 'ribu',
      'juta', 'miliar', 'triliun', 'rupiah', 'minus'
    ];

    List<String> words = wordsString.toLowerCase().split(' ');

    for (String word in words) {
      if (word.isEmpty) continue;

      bool isValidWord = validWords.contains(word) ||
          word.endsWith('belas') ||
          validWords.any((validWord) => word.contains(validWord));

      if (!isValidWord) return false;
    }

    return true;
  }

  /// Helper method untuk memformat angka dengan pemisah ribuan
  ///
  /// [value] - Nilai angka yang akan diformat
  /// [includeDecimals] - Apakah ingin menampilkan desimal
  /// [decimalPlaces] - Jumlah tempat desimal
  ///
  /// Returns: [String] angka yang sudah diformat dengan pemisah ribuan
  static String _formatNumber(num value, bool includeDecimals, int decimalPlaces) {
    String valueStr;

    if (includeDecimals && decimalPlaces > 0) {
      valueStr = value.toStringAsFixed(decimalPlaces);
    } else {
      valueStr = value.toStringAsFixed(0);
    }

    List<String> parts = valueStr.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
    );

    if (includeDecimals && decimalPart.isNotEmpty) {
      return '$formattedInteger,$decimalPart';
    }

    return formattedInteger;
  }

  /// Helper method untuk memformat angka dalam bentuk kompak
  ///
  /// [value] - Nilai angka yang akan diformat
  /// [decimalPlaces] - Jumlah tempat desimal untuk format kompak
  ///
  /// Returns: [String] angka yang sudah diformat dalam bentuk kompak
  static String _formatCompactNumber(num value, int decimalPlaces) {
    double absValue = value.abs().toDouble();

    if (absValue >= 1000000000000) {
      double compactValue = absValue / 1000000000000;
      return '${_formatDecimal(compactValue, decimalPlaces)} T';
    } else if (absValue >= 1000000000) {
      double compactValue = absValue / 1000000000;
      return '${_formatDecimal(compactValue, decimalPlaces)} M';
    } else if (absValue >= 1000000) {
      double compactValue = absValue / 1000000;
      return '${_formatDecimal(compactValue, decimalPlaces)} Jt';
    } else if (absValue >= 1000) {
      double compactValue = absValue / 1000;
      return '${_formatDecimal(compactValue, decimalPlaces)} Rb';
    } else {
      return _formatNumber(value, false, 0);
    }
  }

  /// Helper method untuk memformat desimal dengan koma sebagai pemisah desimal
  ///
  /// [value] - Nilai desimal yang akan diformat
  /// [decimalPlaces] - Jumlah tempat desimal
  ///
  /// Returns: [String] nilai desimal yang sudah diformat
  static String _formatDecimal(double value, int decimalPlaces) {
    String formatted = value.toStringAsFixed(decimalPlaces);
    return formatted.replaceAll('.', ',');
  }

  /// Helper method untuk mengkonversi angka menjadi kata-kata
  ///
  /// [number] - Angka yang akan dikonversi
  ///
  /// Returns: [String] angka dalam bentuk kata-kata bahasa Indonesia
  static String _convertToWords(int number) {
    if (number == 0) return 'nol';

    List<String> ones = [
      '', 'satu', 'dua', 'tiga', 'empat', 'lima', 'enam', 'tujuh', 'delapan', 'sembilan'
    ];

    List<String> teens = [
      'sepuluh', 'sebelas', 'dua belas', 'tiga belas', 'empat belas',
      'lima belas', 'enam belas', 'tujuh belas', 'delapan belas', 'sembilan belas'
    ];

    List<String> tens = [
      '', '', 'dua puluh', 'tiga puluh', 'empat puluh', 'lima puluh',
      'enam puluh', 'tujuh puluh', 'delapan puluh', 'sembilan puluh'
    ];

    String result = '';

    if (number >= 1000000000000) {
      int trillions = number ~/ 1000000000000;
      result += '${_convertHundreds(trillions, ones, teens, tens)} triliun';
      number %= 1000000000000;
      if (number > 0) result += ' ';
    }

    if (number >= 1000000000) {
      int billions = number ~/ 1000000000;
      result += '${_convertHundreds(billions, ones, teens, tens)} miliar';
      number %= 1000000000;
      if (number > 0) result += ' ';
    }

    if (number >= 1000000) {
      int millions = number ~/ 1000000;
      result += '${_convertHundreds(millions, ones, teens, tens)} juta';
      number %= 1000000;
      if (number > 0) result += ' ';
    }

    if (number >= 1000) {
      int thousands = number ~/ 1000;
      if (thousands == 1) {
        result += 'seribu';
      } else {
        result += '${_convertHundreds(thousands, ones, teens, tens)} ribu';
      }
      number %= 1000;
      if (number > 0) result += ' ';
    }

    if (number > 0) {
      result += _convertHundreds(number, ones, teens, tens);
    }

    return result.trim();
  }

  /// Helper method untuk mengkonversi ratusan
  ///
  /// [number] - Angka yang akan dikonversi (0-999)
  /// [ones] - Array kata-kata untuk satuan
  /// [teens] - Array kata-kata untuk belasan
  /// [tens] - Array kata-kata untuk puluhan
  ///
  /// Returns: [String] angka dalam bentuk kata-kata untuk ratusan
  static String _convertHundreds(int number, List<String> ones, List<String> teens, List<String> tens) {
    String result = '';

    if (number >= 100) {
      int hundreds = number ~/ 100;
      if (hundreds == 1) {
        result += 'seratus';
      } else {
        result += '${ones[hundreds]} ratus';
      }
      number %= 100;
      if (number > 0) result += ' ';
    }

    if (number >= 20) {
      int tensDigit = number ~/ 10;
      int onesDigit = number % 10;
      result += tens[tensDigit];
      if (onesDigit > 0) {
        result += ' ${ones[onesDigit]}';
      }
    } else if (number >= 10) {
      result += teens[number - 10];
    } else if (number > 0) {
      result += ones[number];
    }

    return result;
  }
}