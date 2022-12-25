import 'dart:collection';
import 'dart:io';

import 'package:grizzly_io/io_loader.dart';
import 'package:savings_bank_minimum_balance_resolver_common/daily_balance.dart';
import 'package:savings_bank_minimum_balance_resolver_common/date_formats.dart'
    as date_formats;
import 'package:savings_bank_minimum_balance_resolver_common/transaction.dart';
import 'package:savings_bank_minimum_balance_resolver_common/transactions_parser.dart'
    as transactions_parser;
import 'package:savings_bank_minimum_balance_resolver_common/transactions_with_last_balance.dart'
    as transactions_with_last_balance_parser;
import 'package:sugar/collection.dart';

double _getAverageDailyBalance(double sumOfDailyBalances, int numberOfDays) {
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
  return _getAverageDailyBalance(sumOfDailyBalances, dailyBalances.length);
}

Future<double> getCurrentAverageDailyBalanceFromCsv(String csvPath) async {
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

List<Transaction> _readTransactionsFromJson(String jsonPath) {
  Map<String, List<transactions_parser.TransactionAmountJson>>
      parsedTransactions = transactions_parser
          .transactionsFromJson(File(jsonPath).readAsStringSync());
  List<Transaction> transactions = List.empty(growable: true);
  parsedTransactions.forEach((String parsedTransactionDate,
      List<transactions_parser.TransactionAmountJson>
          parsedTransactionAmounts) {
    for (transactions_parser.TransactionAmountJson parsedTransactionAmount
        in parsedTransactionAmounts) {
      transactions.add(Transaction(
          date: date_formats.normalDateFormat.parse(parsedTransactionDate),
          amount: parsedTransactionAmount.amount.toDouble()));
    }
  });
  return transactions;
}

Pair<transactions_with_last_balance_parser.LastBalance, List<Transaction>>
    _readTransactionsWithLastBalanceFromJson(String jsonPath) {
  transactions_with_last_balance_parser.TransactionsWithLastBalance
      parsedTransactions =
      transactions_with_last_balance_parser.transactionsWithLastBalanceFromJson(
          File(jsonPath).readAsStringSync());
  List<Transaction> transactions = List.empty(growable: true);
  parsedTransactions.transactions.forEach(
      (String parsedTransactionDate, List<num> parsedTransactionAmounts) {
    for (num parsedTransactionAmount in parsedTransactionAmounts) {
      transactions.add(Transaction(
          date: date_formats.normalDateFormat.parse(parsedTransactionDate),
          amount: parsedTransactionAmount.toDouble()));
    }
  });
  return Pair(parsedTransactions.lastBalance, transactions);
}

SplayTreeMap<DateTime, double> calculateDailyBalancesFromTransactions(
    DateTime upToDate,
    double lastBalance,
    DateTime fromDate,
    Map<DateTime, double> transactionSums) {
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

Future<Map<DateTime, double>> prepareTransactionSumsFromCsv(
    String csvPath) async {
  return _prepareTransactionSums(await _readTransactionsFromCsv(csvPath));
}

Map<DateTime, double> prepareTransactionSumsFromJson(String jsonPath) {
  return _prepareTransactionSums(_readTransactionsFromJson(jsonPath));
}

Pair<transactions_with_last_balance_parser.LastBalance, Map<DateTime, double>>
    prepareTransactionSumsWithLastBalanceFromJson(String jsonPath) {
  Pair<transactions_with_last_balance_parser.LastBalance, List<Transaction>>
      transactionsWithLastBalance =
      _readTransactionsWithLastBalanceFromJson(jsonPath);
  return Pair(transactionsWithLastBalance.key,
      _prepareTransactionSums(transactionsWithLastBalance.value));
}

Map<DateTime, double> _prepareTransactionSums(List<Transaction> transactions) {
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

Pair<double, double> getAverageDailyBalanceAndSumFromDailyBalanceMap(
    Map<DateTime, double> dailyBalances) {
  double sumOfDailyBalances = 0;
  dailyBalances.forEach((DateTime date, double dailyBalance) {
    sumOfDailyBalances += dailyBalance;
  });
  return Pair(_getAverageDailyBalance(sumOfDailyBalances, dailyBalances.length),
      sumOfDailyBalances);
}

Map<DateTime, Quad<double, double, double, int>>
    prepareForecastWithSolutionForOneTimeAlteredBalance(
        Map<DateTime, double> dailyBalances,
        double minimumBalance,
        double currentAverageDailyBalance,
        double lastBalance,
        {bool isNotSameAmount = true,
        bool isNotTimedOperation = true,
        DateTime? eventDate,
        bool isForDays = false,
        int? forDays}) {
  bool isOneTimeNotOver = true;

  Map<DateTime, Quad<double, double, double, int>> forecastResult = {};

  DateTime lastDay = dailyBalances.keys.last;
  int noOfDays = dailyBalances.length;

  double lastBalanceBackup = lastBalance;

  int dayCounter = 0;

  while (checkLoopCriteria(currentAverageDailyBalance, minimumBalance,
      isForDays, forDays, dayCounter)) {
    lastDay = lastDay.add(Duration(days: 1));

    if (isOneTimeNotOver) {
      if (isNotSameAmount && isNotTimedOperation) {
        lastBalance = dailyBalances.values.last + lastBalance;
        isOneTimeNotOver = false;
      } else {
        if (eventDate != null) {
          if (eventDate.compareTo(lastDay) == 0) {
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

    double sumOfDailyBalancesForExtraOneDay =
        (currentAverageDailyBalance * noOfDays) + lastBalance;
    currentAverageDailyBalance =
        sumOfDailyBalancesForExtraOneDay / (++noOfDays);

    double solutionAmount;
    if (currentAverageDailyBalance > minimumBalance) {
      solutionAmount = 0;
    } else {
      solutionAmount =
          (minimumBalance * noOfDays) - sumOfDailyBalancesForExtraOneDay;
    }

    forecastResult[lastDay] = Quad(currentAverageDailyBalance, solutionAmount,
        sumOfDailyBalancesForExtraOneDay, noOfDays);
    dayCounter++;
  }
  return forecastResult;
}

bool checkLoopCriteria(double currentAverageDailyBalance, double minimumBalance,
    bool isForDays, int? forDays, int dayCounter) {
  if (isForDays) {
    if (forDays != null) {
      return dayCounter < forDays;
    } else {
      // throw exception
      return false;
    }
  } else {
    return currentAverageDailyBalance > minimumBalance;
  }
}

Map<DateTime, Quad<double, double, double, int>> prepareForecastForSameBalance(
    Map<DateTime, double> dailyBalances,
    double minimumBalance,
    double currentAverageDailyBalance) {
  return prepareForecastWithSolutionForOneTimeAlteredBalance(dailyBalances,
      minimumBalance, currentAverageDailyBalance, dailyBalances.values.last,
      isNotSameAmount: false);
}

Map<DateTime, Quad<double, double, double, int>>
    prepareForecastForDaysWithSameBalance(Map<DateTime, double> dailyBalances,
        double minimumBalance, double currentAverageDailyBalance, int forDays) {
  return prepareForecastWithSolutionForOneTimeAlteredBalance(dailyBalances,
      minimumBalance, currentAverageDailyBalance, dailyBalances.values.last,
      isNotSameAmount: false, isForDays: true, forDays: forDays);
}
