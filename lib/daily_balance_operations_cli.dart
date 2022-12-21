import 'dart:io';

import 'package:savings_bank_minimum_balance_resolver_common/daily_balance_operations.dart'
    as daily_balance_operations;
import 'package:savings_bank_minimum_balance_resolver_common/input_utils_cli.dart'
    as input_utils_cli;

Future<Map<DateTime, double>> _calculateDailyBalancesFromTransactionsCsvCli(
    Map<DateTime, double> transactionSums) async {
  DateTime upToDate = _getUpToDateCli(transactionSums.keys.first);
  double lastBalance = input_utils_cli
      .getValidDoubleCli('Enter the last balance on $upToDate : ');
  return daily_balance_operations.calculateDailyBalancesFromTransactionsCsv(
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
          await _calculateDailyBalancesFromTransactionsCsvCli(
              await daily_balance_operations.prepareTransactionSums(csvPath)));
}
