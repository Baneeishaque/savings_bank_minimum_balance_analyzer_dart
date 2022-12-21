import 'dart:collection';

import 'package:grizzly_io/io_loader.dart';
import 'package:savings_bank_minimum_balance_resolver_common/daily_balance.dart';
import 'package:savings_bank_minimum_balance_resolver_common/date_formats.dart'
    as date_formats;
import 'package:savings_bank_minimum_balance_resolver_common/transaction.dart';

double _getCurrentAverageDailyBalance(
    double sumOfDailyBalances, int numberOfDays) {
  return sumOfDailyBalances / numberOfDays;
}

Future<List<DailyBalance>> _readDailyBalancesFromCsv(String csvPath) async {
  List<DailyBalance> dailyBalances = List.empty(growable: true);
  for (List<String> row in (await readCsv(csvPath))) {
    dailyBalances.add(DailyBalance(
        date: date_formats.normalDateFormat.parseStrict(row[0]),
        balance: double.parse(row[1])));
  }
  return dailyBalances;
}

double _getCurrentAverageDailyBalanceFromDailyBalanceList(
    List<DailyBalance> dailyBalances) {
  double sumOfDailyBalances = 0;
  for (DailyBalance dailyBalance in dailyBalances) {
    sumOfDailyBalances += dailyBalance.balance;
  }
  return _getCurrentAverageDailyBalance(
      sumOfDailyBalances, dailyBalances.length);
}

Future<double> _getCurrentAverageDailyBalanceFromCsv(String csvPath) async {
  return _getCurrentAverageDailyBalanceFromDailyBalanceList(
      await _readDailyBalancesFromCsv(csvPath));
}

Future<List<Transaction>> _readTransactionsFromCsv(String csvPath) async {
  List<Transaction> transactions = List.empty(growable: true);
  for (List<String> row in (await readCsv(csvPath))) {
    transactions.add(Transaction(
        date: date_formats.normalDateFormat.parseStrict(row[0]),
        amount: double.parse(row[1])));
  }
  return transactions;
}

Future<Map<DateTime, double>> calculateDailyBalancesFromTransactionsCsv(
    DateTime upToDate,
    double lastBalance,
    DateTime fromDate,
    Map<DateTime, double> transactionSums) async {
  return _fillMissingDailyBalances(_fillDailyBalancesFromDate(
      fromDate,
      _fillDailyBalancesUpToAvailableDate(
          upToDate, transactionSums, lastBalance)));
}

SplayTreeMap<DateTime, double> _fillMissingDailyBalances(
    SplayTreeMap<DateTime, double> dailyBalances) {
  DateTime lowerDate = dailyBalances.keys.first;
  double dayBalance = 0;
  while (lowerDate != dailyBalances.keys.last) {
    if (dailyBalances.containsKey(lowerDate)) {
      dayBalance = dailyBalances[lowerDate]!;
    } else {
      dailyBalances[lowerDate] = dayBalance;
    }
    lowerDate = lowerDate.add(Duration(days: 1));
  }
  return dailyBalances;
}

SplayTreeMap<DateTime, double> _fillDailyBalancesFromDate(
    DateTime? secondFromDate, SplayTreeMap<DateTime, double> dailyBalances) {
  if (secondFromDate != null) {
    DateTime fromDate = dailyBalances.keys.first;
    double lowerBalance = dailyBalances.values.first;
    while (fromDate != secondFromDate) {
      fromDate = fromDate.subtract(Duration(days: 1));
      dailyBalances[fromDate] = lowerBalance;
    }
  }
  return dailyBalances;
}

SplayTreeMap<DateTime, double> _fillDailyBalancesUpToAvailableDate(
    DateTime upToDate,
    Map<DateTime, double> transactionSums,
    double lastBalance) {
  SplayTreeMap<DateTime, double> dailyBalances =
      SplayTreeMap((k1, k2) => k1.compareTo(k2));
  while (upToDate != transactionSums.keys.first) {
    dailyBalances[upToDate] = lastBalance;
    upToDate = upToDate.subtract(Duration(days: 1));
  }
  transactionSums.forEach((key, value) {
    dailyBalances[key] = lastBalance;
    lastBalance += value;
  });
  return dailyBalances;
}

Future<Map<DateTime, double>> prepareTransactionSums(String csvPath) async {
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
  return transactionSums;
}

double getCurrentAverageDailyBalanceFromDailyBalanceMap(
    Map<DateTime, double> dailyBalances) {
  double sumOfDailyBalances = 0;
  dailyBalances.forEach((key, value) {
    sumOfDailyBalances += value;
  });
  return _getCurrentAverageDailyBalance(
      sumOfDailyBalances, dailyBalances.length);
}

Map<DateTime, double> prepareForecastForOneTimeDifferentAmount(
    Map<DateTime, double> dailyBalances,
    double minimumBalance,
    double currentAverageDailyBalance,
    double lastBalance,
    {bool isNotSameAmount = true,
    bool isNotTimedOperation = true,
    DateTime? eventDate}) {
  bool isOneTimeNotOver = true;
  Map<DateTime, double> forecastResult = {};
  DateTime lastDay = dailyBalances.keys.last;
  int noOfDays = dailyBalances.length;
  double lastBalanceBackup = lastBalance;
  while (currentAverageDailyBalance > minimumBalance) {
    if (isOneTimeNotOver) {
      if (isNotSameAmount && isNotTimedOperation) {
        lastBalance = dailyBalances.values.last + lastBalance;
        isOneTimeNotOver = false;
      } else {
        if (eventDate != null) {
          if (eventDate.compareTo(lastDay.add(Duration(days: 1))) == 0) {
            lastBalance = dailyBalances.values.last + lastBalanceBackup;
            isOneTimeNotOver = false;
          } else {
            lastBalance = dailyBalances.values.last;
          }
        } else {
          // throw exception
        }
      }
    }
    currentAverageDailyBalance =
        ((currentAverageDailyBalance * noOfDays) + lastBalance) / (++noOfDays);
    lastDay = lastDay.add(Duration(days: 1));
    forecastResult[lastDay] = currentAverageDailyBalance;
  }
  return forecastResult;
}

Map<DateTime, double> prepareForecastForSameAmount(
    Map<DateTime, double> dailyBalances,
    double minimumBalance,
    double currentAverageDailyBalance) {
  return prepareForecastForOneTimeDifferentAmount(dailyBalances, minimumBalance,
      currentAverageDailyBalance, dailyBalances.values.last,
      isNotSameAmount: false);
}
