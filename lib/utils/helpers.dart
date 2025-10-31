import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date, {String pattern = 'dd MMM yyyy'}) {
    return DateFormat(pattern, 'id_ID').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  static String formatDateOnly(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  static String formatDayMonth(DateTime date) {
    return DateFormat('dd MMM', 'id_ID').format(date);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}

class CurrencyFormatter {
  static String format(double amount, {String symbol = 'Rp'}) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return '$symbol ${formatter.format(amount)}';
  }

  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(amount);
  }
}

class Validator {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegex = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) {
      return 'Nomor telepon tidak valid';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName harus diisi';
    }

    if (int.tryParse(value) == null) {
      return '$fieldName harus berupa angka';
    }

    if (int.parse(value) < 0) {
      return '$fieldName harus positif';
    }

    return null;
  }

  static String? validateISBN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // ISBN is optional
    }

    // Remove hyphens and spaces
    final isbn = value.replaceAll(RegExp(r'[\s-]'), '');

    // ISBN can be 10 or 13 digits
    if (isbn.length != 10 && isbn.length != 13) {
      return 'ISBN harus 10 atau 13 digit';
    }

    return null;
  }
}
