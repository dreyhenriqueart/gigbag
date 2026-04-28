import 'package:intl/intl.dart';

final _dateFormat = DateFormat('dd/MM/yyyy');
final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

String formatDate(DateTime dt) => _dateFormat.format(dt);
String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);

