import 'dart:io';

import 'package:intl/intl.dart';

import 'date_formats.dart';

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

DateTime getValidDate(DateFormat dateFormat) {
  print('Enter the date in ${dateFormat.pattern} format :');
  String? dateInText = stdin.readLineSync();
  if (dateInText == null) {
    return getValidDate(dateFormat);
  } else {
    try {
      return dateFormat.parse(dateInText);
    } on FormatException catch (exception) {
      print('Exception : $exception');
      return getValidDate(dateFormat);
    }
  }
}

DateTime getValidGreaterDate(DateTime otherDate, DateFormat dateFormat) {
  DateTime date = getValidDate(dateFormat);
  if (date.compareTo(otherDate) > 0) {
    return date;
  } else {
    return getValidGreaterDate(otherDate, dateFormat);
  }
}

DateTime getValidLowerDate(DateTime otherDate, DateFormat dateFormat) {
  DateTime date = getValidDate(dateFormat);
  if (date.compareTo(otherDate) < 0) {
    return date;
  } else {
    return getValidLowerDate(otherDate, dateFormat);
  }
}

DateTime getValidNormalDate() {
  return getValidDate(normalDateFormat);
}

DateTime getValidNormalGreaterDateCli(DateTime otherDate) {
  return getValidGreaterDate(otherDate, normalDateFormat);
}

DateTime getValidNormalLowerDateCli(DateTime otherDate) {
  return getValidLowerDate(otherDate, normalDateFormat);
}
