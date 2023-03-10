import 'dart:collection';
import 'dart:io';

import 'package:savings_bank_minimum_balance_resolver_common/daily_balance_operations.dart'
    as daily_balance_operations;
import 'package:savings_bank_minimum_balance_resolver_common/date_formats.dart';
import 'package:savings_bank_minimum_balance_resolver_common/input_utils_cli.dart'
    as input_utils_cli;
import 'package:savings_bank_minimum_balance_resolver_common/transactions_with_last_balance.dart'
    as transactions_with_last_balance_parser;
import 'package:sugar/collection.dart';

SplayTreeMap<DateTime, double> calculateDailyBalancesFromTransactionSumsCli(
    Map<DateTime, double> transactionSums) {
  DateTime upToDate = _getUpToDateCli(transactionSums.keys.first);
  double lastBalance = input_utils_cli
      .getValidDoubleCli('Enter the last balance on $upToDate : ');
  return daily_balance_operations.calculateDailyBalancesFromTransactions(
      upToDate,
      lastBalance,
      _getFromDateCli(transactionSums.keys.last),
      transactionSums);
}

DateTime _getUpToDateCli(DateTime upToDate) {
  print(
      'Calculate Daily Balance up-to $upToDate (Y/N - Just Enter for Yes) : ');
  String? upToDateInput = stdin.readLineSync();
  if (upToDateInput != "") {
    upToDate = input_utils_cli.getValidNormalGreaterDateCli(upToDate);
  }
  return upToDate;
}

DateTime _getFromDateCli(DateTime fromDate) {
  if (fromDate.day != 1) {
    print(
        'Calculate Daily Balance from $fromDate (Y/N - Just Enter for Yes) : ');
    String? fromDateInput = stdin.readLineSync();
    if (fromDateInput != "") {
      fromDate = input_utils_cli.getValidNormalLowerDateCli(fromDate);
    }
  }
  return fromDate;
}

Future<Pair<double, double>>
    getAverageDailyBalanceWithSumFromTransactionsCsvCli(String csvPath) async {
  return daily_balance_operations
      .getAverageDailyBalanceAndSumFromDailyBalanceMap(
          calculateDailyBalancesFromTransactionSumsCli(
              await daily_balance_operations
                  .prepareTransactionSumsFromCsv(csvPath)));
}

SplayTreeMap<DateTime, double>
    calculateDailyBalancesFromTransactionSumsWithLastBalanceCli(
        Pair<transactions_with_last_balance_parser.LastBalance,
                Map<DateTime, double>>
            transactionSumsWithLastBalance) {
  if (transactionSumsWithLastBalance.value.keys.first.compareTo(
          normalDateFormat.parse(transactionSumsWithLastBalance.key.date)) >=
      0) {
    print('outdated last balance');
    //throw exception
  }
  return daily_balance_operations.calculateDailyBalancesFromTransactions(
      normalDateFormat.parse(transactionSumsWithLastBalance.key.date),
      transactionSumsWithLastBalance.key.amount.toDouble(),
      _getFromDateCli(transactionSumsWithLastBalance.value.keys.last),
      transactionSumsWithLastBalance.value);
}

Map<DateTime, Triple<double, double, double>>
    prepareForecastForDaysWithSameBalanceAndOneTimeResolve(
        Map<DateTime, double> dailyBalances,
        double minimumBalance,
        double currentAverageDailyBalance,
        int forDays) {
  Map<DateTime, Quad<double, double, double, int>> forecastResult =
      daily_balance_operations.prepareForecastForDaysWithSameBalance(
          dailyBalances, minimumBalance, currentAverageDailyBalance, forDays);
  Map<DateTime, Triple<double, double, double>> forecastResultWithRepay = {};
  bool isOneTimeResolveIsNotOver = true;
  double oneTimeResolveAmount = 0;
  double previousDailyBalancesSum = 0;
  for (DateTime date in forecastResult.keys) {
    if (forecastResult[date]!.second != 0) {
      if (isOneTimeResolveIsNotOver) {
        print(
            'Need to pay ${forecastResult[date]!.second} on $date, OK (Y/N - Just Enter for Yes) : ');
        String? solutionPayInput = stdin.readLineSync();
        if (solutionPayInput == "") {
          forecastResultWithRepay[date] = Triple(forecastResult[date]!.first,
              forecastResult[date]!.second, forecastResult[date]!.second);
          isOneTimeResolveIsNotOver = false;
          oneTimeResolveAmount = forecastResult[date]!.second;
          previousDailyBalancesSum = forecastResult[date]!.third;
        } else {
          forecastResultWithRepay[date] = Triple(
              forecastResult[date]!.first, forecastResult[date]!.second, 0);
        }
      } else {
        forecastResultWithRepay[date] = Triple(
            minimumBalance,
            0,
            ((forecastResult[date]!.third - previousDailyBalancesSum) +
                    oneTimeResolveAmount) -
                minimumBalance);
        break;
      }
    } else {
      //TODO : Improve Triple : Constructor of Pair, right items
      forecastResultWithRepay[date] =
          Triple(forecastResult[date]!.first, forecastResult[date]!.second, 0);
    }
  }
  return forecastResultWithRepay;
}
