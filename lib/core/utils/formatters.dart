import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );

  static final _date = DateFormat('dd \'de\' MMMM \'de\' yyyy', 'es');
  static final _dateShort = DateFormat('dd/MM/yyyy', 'es');
  static final _monthYear = DateFormat('MMMM yyyy', 'es');

  static String currency(double amount) => _currency.format(amount);

  static String date(DateTime date) => _date.format(date);

  static String dateShort(DateTime date) => _dateShort.format(date);

  static String monthYear(DateTime date) {
    final formatted = _monthYear.format(date);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return dateShort(dateTime);
  }
}
