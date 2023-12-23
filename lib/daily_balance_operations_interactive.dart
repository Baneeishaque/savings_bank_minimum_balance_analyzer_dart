import 'dart:collection';
import 'dart:io';

import 'package:savings_bank_minimum_balance_analyzer_dart/models/map_for_forecast_model.dart';
import 'package:savings_bank_minimum_balance_analyzer_dart/models/tuple_for_forecast_model.dart';
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

MapForForecastModel<DateTime,
        Tuple5ForForecastForDaysWithSameBalanceAndOneTimeResolveModel>
    prepareForecastForDaysWithSameBalanceAndOneTimeResolve(
  Map<DateTime, double> dailyBalances,
  double minimumBalance,
  double currentAverageDailyBalance,
  int forDays,
) {
  // date => [currentAverageDailyBalance, solutionAmount, sumOfDailyBalances, noOfDays]
  MapForForecastModel<DateTime,
          Tuple4ForForecastWithSolutionForOneTimeAlteredBalanceModel>
      forecastResult =
      daily_balance_operations.prepareForecastForDaysWithSameBalance(
          dailyBalances, minimumBalance, currentAverageDailyBalance, forDays);
  // date => [currentAverageDailyBalance, solutionAmount, repayAmount, paidAmount, advantageAmount]
  MapForForecastModel<DateTime,
          Tuple5ForForecastForDaysWithSameBalanceAndOneTimeResolveModel>
      forecastResultWithRepay = MapForForecastModel();
  bool isOneTimeResolveIsNotOver = true;
  double oneTimeResolveAmount = 0;
  double previousDailyBalancesSum = 0;
  for (DateTime date in forecastResult.keys) {
    if (forecastResult[date]!.solutionAmount != 0) {
      if (isOneTimeResolveIsNotOver) {
        print(
            'Need to pay ${forecastResult[date]!.solutionAmount} on $date, OK (Y/N - Just Enter for Yes) : ');
        String? solutionPayInput = stdin.readLineSync();
        if (solutionPayInput == "") {
          forecastResultWithRepay[date] =
              Tuple5ForForecastForDaysWithSameBalanceAndOneTimeResolveModel(
                  forecastResult[date]!.currentAverageDailyBalance,
                  forecastResult[date]!.solutionAmount,
                  0,
                  forecastResult[date]!.solutionAmount,
                  0);
          isOneTimeResolveIsNotOver = false;
          oneTimeResolveAmount = forecastResult[date]!.solutionAmount;
          previousDailyBalancesSum = forecastResult[date]!.sumOfDailyBalances;
        } else {
          forecastResultWithRepay[date] =
              Tuple5ForForecastForDaysWithSameBalanceAndOneTimeResolveModel(
                  forecastResult[date]!.currentAverageDailyBalance,
                  forecastResult[date]!.solutionAmount,
                  0,
                  0,
                  0);
        }
      } else {
        double repayAmount = ((forecastResult[date]!.sumOfDailyBalances -
                    previousDailyBalancesSum) +
                oneTimeResolveAmount) -
            minimumBalance;
        forecastResultWithRepay[date] =
            Tuple5ForForecastForDaysWithSameBalanceAndOneTimeResolveModel(
                minimumBalance,
                0,
                repayAmount,
                0,
                (repayAmount - oneTimeResolveAmount));
        break;
      }
    } else {
      forecastResultWithRepay[date] =
          Tuple5ForForecastForDaysWithSameBalanceAndOneTimeResolveModel(
              forecastResult[date]!.currentAverageDailyBalance,
              forecastResult[date]!.solutionAmount,
              0,
              0,
              0);
    }
  }
  return forecastResultWithRepay;
}
