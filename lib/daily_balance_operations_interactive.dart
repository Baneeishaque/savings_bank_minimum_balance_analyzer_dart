import 'dart:collection';
import 'dart:io';

import 'package:tuple/tuple.dart';

import 'daily_balance_operations.dart' as daily_balance_operations;
import 'date_formats.dart';
import 'input_utils_interactive.dart' as input_utils_cli;
import 'models/transactions_with_last_balance_model.dart'
    as transactions_with_last_balance_parser;

SplayTreeMap<DateTime, double> calculateDailyBalancesFromTransactionSumsCli(
    Map<DateTime, double> transactionSums) {
  DateTime upToDate = getUpToDateCli(transactionSums.keys.first);
  double lastBalance = input_utils_cli
      .getValidDoubleCli('Enter the last balance on $upToDate : ');
  return daily_balance_operations.calculateDailyBalancesFromTransactions(
      upToDate,
      lastBalance,
      getFromDateCli(transactionSums.keys.last),
      transactionSums);
}

DateTime getUpToDateCli(DateTime upToDate) {
  print(
      'Calculate Daily Balance up-to $upToDate (Y/N - Just Enter for Yes) : ');
  String? upToDateInput = stdin.readLineSync();
  if (upToDateInput != "") {
    upToDate = input_utils_cli.getValidNormalGreaterDateCli(upToDate);
  }
  return upToDate;
}

DateTime getFromDateCli(DateTime fromDate) {
  if (fromDate.day != 1) {
    print(
        'Calculate Daily Balance from $fromDate (Y/N - Just Enter for Yes) : ');
    String? fromDateInput = stdin.readLineSync();
    if (fromDateInput != "") {
      fromDate = input_utils_cli.getValidNormalGreaterDateCli(fromDate);
    }
  }
  return fromDate;
}

Future<Tuple2<double, double>>
    getAverageDailyBalanceWithSumFromTransactionsCsvCli(String csvPath) async {
  return daily_balance_operations
      .getAverageDailyBalanceAndSumFromDailyBalanceMap(
          calculateDailyBalancesFromTransactionSumsCli(
              await daily_balance_operations
                  .prepareTransactionSumsFromCsv(csvPath)));
}

SplayTreeMap<DateTime, double>
    calculateDailyBalancesFromTransactionSumsWithLastBalanceCli(
        Tuple2<transactions_with_last_balance_parser.LastBalance,
                Map<DateTime, double>>
            transactionSumsWithLastBalance) {
  if (transactionSumsWithLastBalance.item2.keys.last.compareTo(
          normalDateFormat.parse(transactionSumsWithLastBalance.item1.date)) >
      0) {
    print('outdated last balance');
    //throw exception
  }
  return daily_balance_operations.calculateDailyBalancesFromTransactions(
      normalDateFormat.parse(transactionSumsWithLastBalance.item1.date),
      transactionSumsWithLastBalance.item1.amount.toDouble(),
      getFromDateCli(transactionSumsWithLastBalance.item2.keys.first),
      transactionSumsWithLastBalance.item2);
}

Map<DateTime, Tuple4<double, double, double, double>>
    prepareForecastForDaysWithSameBalanceAndOneTimeResolve(
        Map<DateTime, double> dailyBalances,
        double minimumBalance,
        double currentAverageDailyBalance,
        int forDays) {
  // date => [currentAverageDailyBalance, solutionAmount, sumOfDailyBalancesForExtraOneDay, noOfDays]
  Map<DateTime, Tuple4<double, double, double, int>> forecastResult =
      daily_balance_operations.prepareForecastForDaysWithSameBalance(
          dailyBalances, minimumBalance, currentAverageDailyBalance, forDays);
  // date => [currentAverageDailyBalance, solutionAmount
  Map<DateTime, Tuple4<double, double, double, double>>
      forecastResultWithRepay = {};
  bool isOneTimeResolveIsNotOver = true;
  double oneTimeResolveAmount = 0;
  double previousDailyBalancesSum = 0;
  for (DateTime date in forecastResult.keys) {
    if (forecastResult[date]!.item2 != 0) {
      if (isOneTimeResolveIsNotOver) {
        print(
            'Need to pay ${forecastResult[date]!.item2} on $date, OK (Y/N - Just Enter for Yes) : ');
        String? solutionPayInput = stdin.readLineSync();
        if (solutionPayInput == "") {
          forecastResultWithRepay[date] = Tuple4(forecastResult[date]!.item1,
              forecastResult[date]!.item2, forecastResult[date]!.item2, 0);
          isOneTimeResolveIsNotOver = false;
          oneTimeResolveAmount = forecastResult[date]!.item2;
          previousDailyBalancesSum = forecastResult[date]!.item3;
        } else {
          forecastResultWithRepay[date] = Tuple4(
              forecastResult[date]!.item1, forecastResult[date]!.item2, 0, 0);
        }
      } else {
        forecastResultWithRepay[date] = Tuple4(
            minimumBalance,
            0,
            ((forecastResult[date]!.item3 - previousDailyBalancesSum) +
                    oneTimeResolveAmount) -
                minimumBalance,
            0);
        break;
      }
    } else {
      //TODO : Improve Triple : Constructor of Tuple2, right items
      forecastResultWithRepay[date] = Tuple4(
          forecastResult[date]!.item1, forecastResult[date]!.item2, 0, 0);
    }
  }
  return forecastResultWithRepay;
}
