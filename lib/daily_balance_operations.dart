import 'dart:io';

import 'package:grizzly_io/io_loader.dart';
import 'package:intl/intl.dart';
import 'package:savings_bank_minimum_balance_resolver_common/daily_balance.dart';
import 'package:savings_bank_minimum_balance_resolver_common/date_formats.dart';
import 'package:savings_bank_minimum_balance_resolver_common/transaction.dart';

double _getCurrentAverageDailyBalance(
    double sumOfDailyBalances, int numberOfDays) {
  return sumOfDailyBalances / numberOfDays;
}

double _getCurrentAverageDailyBalanceFromDailyBalanceList(List<DailyBalance> dailyBalances) {
  double sumOfDailyBalances = 0;
  for (DailyBalance dailyBalance in dailyBalances) {
    sumOfDailyBalances += dailyBalance.balance;
  }
  return _getCurrentAverageDailyBalance(
      sumOfDailyBalances, dailyBalances.length);
}

Future<List<DailyBalance>> _readDailyBalancesFromCsv(String csvPath) async {
  List<DailyBalance> dailyBalances = List.empty(growable: true);
  for (List<String> row in (await readCsv(csvPath))) {
    dailyBalances.add(DailyBalance(
        date: normalDateFormat.parseStrict(row[0]),
        balance: double.parse(row[1])));
  }
  return dailyBalances;
}

Future<double> getCurrentAverageDailyBalanceFromCsv(String csvPath) async {
  return _getCurrentAverageDailyBalanceFromDailyBalanceList(
      await _readDailyBalancesFromCsv(csvPath));
}

Future<List<Transaction>> _readTransactionsFromCsv(String csvPath) async {
  List<Transaction> transactions = List.empty(growable: true);
  for (List<String> row in (await readCsv(csvPath))) {
    transactions.add(Transaction(
        date: normalDateFormat.parseStrict(row[0]),
        amount: double.parse(row[1])));
  }
  return transactions;
}

Future<List<DailyBalance>> calculateDailyBalancesFromTransactionsCsv(
    String csvPath) async {
  List<Transaction> transactions = await _readTransactionsFromCsv(csvPath);
  Map<DateTime, double> transactionSums = {};
  DateTime? currentDateOfTransaction;
  double currentDayTransactionBalance = 0;
  for (Transaction transaction in transactions) {
    currentDateOfTransaction ??= transaction.date;
    if (transaction == transactions.last) {
      transactionSums[currentDateOfTransaction] =
          currentDayTransactionBalance + transaction.amount;
      break;
    } else if (currentDateOfTransaction.compareTo(transaction.date) != 0) {
      transactionSums[currentDateOfTransaction] = currentDayTransactionBalance;
      currentDateOfTransaction = transaction.date;
      currentDayTransactionBalance = 0;
    }
    currentDayTransactionBalance += transaction.amount;
  }

  DateTime upToDate = transactionSums.keys.first;
  print(
      'Calculate Daily Balance up-to $upToDate (Y/N - Just Enter for Yes) : ');
  String? input = stdin.readLineSync();
  if (input != "") {
    upToDate = getValidNormalGreaterDate(upToDate);
  }
  double lastBalance = getValidDouble('Enter the last balance on $upToDate : ');
  List<DailyBalance> dailyBalances = List.empty(growable: true);
  while (upToDate != transactionSums.keys.first) {
    dailyBalances.add(DailyBalance(date: upToDate, balance: lastBalance));
    upToDate = upToDate.subtract(Duration(days: 1));
  }
  transactionSums.forEach((key, value) {
    dailyBalances.add(DailyBalance(date: key, balance: lastBalance));
    lastBalance += value;
  });
  return dailyBalances;
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

double getValidDouble(String prompt) {
  print(prompt);
  String? doubleInText = stdin.readLineSync();
  if (doubleInText == null) {
    return getValidDouble(prompt);
  } else {
    try {
      return double.parse(doubleInText);
    } on FormatException catch (exception) {
      print('Exception : $exception');
      return getValidDouble(prompt);
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

DateTime getValidNormalDate() {
  return getValidDate(normalDateFormat);
}

DateTime getValidNormalGreaterDate(DateTime otherDate) {
  return getValidGreaterDate(otherDate, normalDateFormat);
}
