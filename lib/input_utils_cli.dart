import 'dart:io';

import 'package:intl/intl.dart';

import 'date_formats.dart' as date_formats;

double getValidDoubleCli(String prompt) {
  print(prompt);
  String? doubleInText = stdin.readLineSync();
  if (doubleInText == null) {
    return getValidDoubleCli(prompt);
  } else {
    try {
      return double.parse(doubleInText);
    } on FormatException catch (exception) {
      print('Exception : $exception');
      return getValidDoubleCli(prompt);
    }
  }
}

DateTime getValidDateCli(DateFormat dateFormat) {
  print('Enter the date in ${dateFormat.pattern} format :');
  String? dateInText = stdin.readLineSync();
  if (dateInText == null) {
    return getValidDateCli(dateFormat);
  } else {
    try {
      return dateFormat.parse(dateInText);
    } on FormatException catch (exception) {
      print('Exception : $exception');
      return getValidDateCli(dateFormat);
    }
  }
}

DateTime getValidGreaterDateCli(DateTime otherDate, DateFormat dateFormat) {
  DateTime date = getValidDateCli(dateFormat);
  if (date.compareTo(otherDate) > 0) {
    return date;
  } else {
    return getValidGreaterDateCli(otherDate, dateFormat);
  }
}

DateTime getValidLowerDateCli(DateTime otherDate, DateFormat dateFormat) {
  DateTime date = getValidDateCli(dateFormat);
  if (date.compareTo(otherDate) < 0) {
    return date;
  } else {
    return getValidLowerDateCli(otherDate, dateFormat);
  }
}

DateTime getValidNormalDateCli() {
  return getValidDateCli(date_formats.normalDateFormat);
}

DateTime getValidNormalGreaterDateCli(DateTime otherDate) {
  return getValidGreaterDateCli(otherDate, date_formats.normalDateFormat);
}

DateTime getValidNormalLowerDateCli(DateTime otherDate) {
  return getValidLowerDateCli(otherDate, date_formats.normalDateFormat);
}
