import 'dart:collection';
import 'dart:io';

import 'package:grizzly_io/grizzly_io.dart';
import 'package:tuple/tuple.dart';

import 'date_formats.dart' as date_formats;
import 'models/daily_balance_model.dart';
import 'models/transaction_amount_model.dart' as transactions_parser;
import 'models/transaction_model.dart';
import 'models/transactions_with_last_balance_model.dart'
    as transactions_with_last_balance_parser;

double getAverageDailyBalance(double sumOfDailyBalances, int numberOfDays) {
  return sumOfDailyBalances / numberOfDays;
}

Future<List<DailyBalanceModel>> readDailyBalancesFromCsv(String csvPath) async {
  List<DailyBalanceModel> dailyBalances = List.empty(growable: true);
  for (List<String> row in (await csv.read(csvPath))) {
    dailyBalances.add(DailyBalanceModel(
        date: date_formats.normalDateFormat.parseStrict(row[0]),
        balance: double.parse(row[1])));
  }
  return dailyBalances;
}

double getAverageDailyBalanceFromDailyBalanceList(
    List<DailyBalanceModel> dailyBalances) {
  double sumOfDailyBalances = 0;
  for (DailyBalanceModel dailyBalance in dailyBalances) {
    sumOfDailyBalances += dailyBalance.balance;
  }
  return getAverageDailyBalance(sumOfDailyBalances, dailyBalances.length);
}

Future<double> getCurrentAverageDailyBalanceFromCsv(String csvPath) async {
  return getAverageDailyBalanceFromDailyBalanceList(
      await readDailyBalancesFromCsv(csvPath));
}

Future<List<TransactionModel>> readTransactionsFromCsv(String csvPath) async {
  List<TransactionModel> transactions = List.empty(growable: true);
  for (List<String> row in (await csv.read(csvPath))) {
    transactions.add(TransactionModel(
        date: date_formats.normalDateFormat.parseStrict(row[0]),
        amount: double.parse(row[1])));
  }
  return transactions;
}

List<TransactionModel> readTransactionsFromJson(String jsonPath) {
  Map<String, List<transactions_parser.TransactionAmountModel>>
      parsedTransactions = transactions_parser
          .transactionAmountFromJson(File(jsonPath).readAsStringSync());
  List<TransactionModel> transactions = List.empty(growable: true);
  parsedTransactions.forEach((String parsedTransactionDate,
      List<transactions_parser.TransactionAmountModel>
          parsedTransactionAmounts) {
    for (transactions_parser.TransactionAmountModel parsedTransactionAmount
        in parsedTransactionAmounts) {
      transactions.add(TransactionModel(
          date: date_formats.normalDateFormat.parse(parsedTransactionDate),
          amount: parsedTransactionAmount.amount.toDouble()));
    }
  });
  return transactions;
}

Tuple2<transactions_with_last_balance_parser.LastBalance,
        List<TransactionModel>>
    readTransactionsWithLastBalanceFromJson(String jsonPath) {
  transactions_with_last_balance_parser.TransactionsWithLastBalanceModel
      parsedTransactions =
      transactions_with_last_balance_parser.transactionsWithLastBalanceFromJson(
          File(jsonPath).readAsStringSync());
  List<TransactionModel> transactions = List.empty(growable: true);
  parsedTransactions.transactions.forEach(
      (String parsedTransactionDate, List<num> parsedTransactionAmounts) {
    for (num parsedTransactionAmount in parsedTransactionAmounts) {
      transactions.add(TransactionModel(
          date: date_formats.normalDateFormat.parse(parsedTransactionDate),
          amount: parsedTransactionAmount.toDouble()));
    }
  });
  return Tuple2(parsedTransactions.lastBalance, transactions);
}

SplayTreeMap<DateTime, double> calculateDailyBalancesFromTransactions(
  DateTime upToDate,
  double lastBalance,
  DateTime fromDate,
  Map<DateTime, double> transactionSums,
) {
  return fillMissingDailyBalances(
      prepareDailyBalances(transactionSums), upToDate, lastBalance);
}

SplayTreeMap<DateTime, double> fillMissingDailyBalances(
    SplayTreeMap<DateTime, double> dailyBalances,
    DateTime upToDate,
    double lastBalance) {
  DateTime lowerDate = dailyBalances.keys.first;
  double dayBalance = 0;
  while (lowerDate != upToDate) {
    if (dailyBalances.containsKey(lowerDate)) {
      dayBalance = dailyBalances[lowerDate]!;
    } else {
      dailyBalances[lowerDate] = dayBalance;
    }
    lowerDate = lowerDate.add(Duration(days: 1));
  }
  dailyBalances[upToDate] = lastBalance;
  return dailyBalances;
}

SplayTreeMap<DateTime, double> fillDailyBalancesFromDate(
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

SplayTreeMap<DateTime, double> prepareDailyBalances(
    Map<DateTime, double> transactionSums) {
  SplayTreeMap<DateTime, double> dailyBalances =
      SplayTreeMap((k1, k2) => k1.compareTo(k2));

  double lastBalance = 0;
  transactionSums.forEach((transactionDate, transactionSum) {
    lastBalance = lastBalance + transactionSum;
    dailyBalances[transactionDate] = lastBalance;
  });

  return dailyBalances;
}

Future<Map<DateTime, double>> prepareTransactionSumsFromCsv(
    String csvPath) async {
  return prepareTransactionSums(await readTransactionsFromCsv(csvPath));
}

Map<DateTime, double> prepareTransactionSumsFromJson(String jsonPath) {
  return prepareTransactionSums(readTransactionsFromJson(jsonPath));
}

Tuple2<transactions_with_last_balance_parser.LastBalance, Map<DateTime, double>>
    prepareTransactionSumsWithLastBalanceFromJson(String jsonPath) {
  Tuple2<transactions_with_last_balance_parser.LastBalance,
          List<TransactionModel>> transactionsWithLastBalance =
      readTransactionsWithLastBalanceFromJson(jsonPath);
  return Tuple2(transactionsWithLastBalance.item1,
      prepareTransactionSums(transactionsWithLastBalance.item2));
}

Map<DateTime, double> prepareTransactionSums(
    List<TransactionModel> transactions) {
  Map<DateTime, double> transactionSums = {};

  for (TransactionModel transaction in transactions) {
    transactionSums[transaction.date] =
        (transactionSums[transaction.date] ?? 0) + transaction.amount;
  }

  return transactionSums;
}

Tuple2<double, double> getAverageDailyBalanceAndSumFromDailyBalanceMap(
    Map<DateTime, double> dailyBalances) {
  double sumOfDailyBalances = 0;
  dailyBalances.forEach((DateTime date, double dailyBalance) {
    sumOfDailyBalances += dailyBalance;
  });
  return Tuple2(
      getAverageDailyBalance(sumOfDailyBalances, dailyBalances.length),
      sumOfDailyBalances);
}

Map<DateTime, Tuple4<double, double, double, int>>
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

  // date => [currentAverageDailyBalance, solutionAmount, sumOfDailyBalancesForExtraOneDay, noOfDays]
  Map<DateTime, Tuple4<double, double, double, int>> forecastResult = {};

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

    forecastResult[lastDay] = Tuple4(currentAverageDailyBalance, solutionAmount,
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

Map<DateTime, Tuple4<double, double, double, int>>
    prepareForecastForSameBalance(Map<DateTime, double> dailyBalances,
        double minimumBalance, double currentAverageDailyBalance) {
  return prepareForecastWithSolutionForOneTimeAlteredBalance(dailyBalances,
      minimumBalance, currentAverageDailyBalance, dailyBalances.values.last,
      isNotSameAmount: false);
}

// date => [currentAverageDailyBalance, solutionAmount, sumOfDailyBalancesForExtraOneDay, noOfDays]
Map<DateTime, Tuple4<double, double, double, int>>
    prepareForecastForDaysWithSameBalance(Map<DateTime, double> dailyBalances,
        double minimumBalance, double currentAverageDailyBalance, int forDays) {
  return prepareForecastWithSolutionForOneTimeAlteredBalance(dailyBalances,
      minimumBalance, currentAverageDailyBalance, dailyBalances.values.last,
      isNotSameAmount: false, isForDays: true, forDays: forDays);
}
