import 'dart:collection';
import 'dart:io';

import 'package:dartx/dartx.dart';
import 'package:savings_bank_minimum_balance_resolver_common/daily_balance_operations.dart'
    as daily_balance_operations;
import 'package:savings_bank_minimum_balance_resolver_common/date_formats.dart';
import 'package:savings_bank_minimum_balance_resolver_common/input_utils_cli.dart'
    as input_utils_cli;
import 'package:savings_bank_minimum_balance_resolver_common/transactions_with_last_balance.dart'
    as transactions_with_last_balance_parser;

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
  print('Calculate Daily Balance from $fromDate (Y/N - Just Enter for Yes) : ');
  String? fromDateInput = stdin.readLineSync();
  if (fromDateInput != "") {
    fromDate = input_utils_cli.getValidNormalLowerDateCli(fromDate);
  }
  return fromDate;
}

Future<double> getCurrentAverageDailyBalanceFromTransactionsCsvCli(
    String csvPath) async {
  return daily_balance_operations
      .getCurrentAverageDailyBalanceFromDailyBalanceMap(
          calculateDailyBalancesFromTransactionSumsCli(
              await daily_balance_operations
                  .prepareTransactionSumsFromCsv(csvPath)));
}

SplayTreeMap<DateTime, double>
    calculateDailyBalancesFromTransactionSumsWithLastBalanceCli(
        Pair<transactions_with_last_balance_parser.LastBalance,
                Map<DateTime, double>>
            transactionSumsWithLastBalance) {
  DateTime upToDate =
      _getUpToDateCli(transactionSumsWithLastBalance.second.keys.first);
  double lastBalance;
  if (upToDate.compareTo(
          normalDateFormat.parse(transactionSumsWithLastBalance.first.date)) ==
      0) {
    lastBalance = transactionSumsWithLastBalance.first.amount.toDouble();
  } else {
    lastBalance = input_utils_cli
        .getValidDoubleCli('Enter the last balance on $upToDate : ');
  }
  return daily_balance_operations.calculateDailyBalancesFromTransactions(
      upToDate,
      lastBalance,
      _getFromDateCli(transactionSumsWithLastBalance.second.keys.last),
      transactionSumsWithLastBalance.second);
}
