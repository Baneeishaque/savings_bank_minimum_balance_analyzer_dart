import 'dart:io';

import 'package:savings_bank_minimum_balance_resolver_common/constants.dart'
    as constants;
import 'package:savings_bank_minimum_balance_resolver_common/daily_balance_operations.dart'
    as daily_balance_operations;
import 'package:savings_bank_minimum_balance_resolver_common/daily_balance_operations_cli.dart'
    as daily_balance_operations_cli;
import 'package:savings_bank_minimum_balance_resolver_common/input_utils_cli.dart'
    as input_utils_cli;

void main(List<String> arguments) async {
  Map<DateTime, double> dailyBalances = await daily_balance_operations_cli
      .calculateDailyBalancesFromTransactionsCsvCli(
          await daily_balance_operations
              .prepareTransactionSums('transactions.csv'));
  double currentAverageDailyBalance = daily_balance_operations
      .getCurrentAverageDailyBalanceFromDailyBalanceMap(dailyBalances);
  print('Average Daily Balance : $currentAverageDailyBalance');
  print('Do you want forecast (Y/N - Just Enter for Yes) : ');
  String? input = stdin.readLineSync();
  if (input == "") {
    print(
        'Forecast within minimum balance => With Same amount (Just Enter) or Altered Amount: ');
    input = stdin.readLineSync();
    double minimumBalance = input_utils_cli.getValidDoubleWithCustomInputsCli(
        'Enter Minimum Balance (K for KGB Minimum Balance, P for PNB Minimum Balance, Amount for Others) : ',
        {"K": constants.kgbMinimumBalance, "P": constants.pnbMinimumBalance});
    if (input == "") {
      print(
          'Forecast\n----------\n${daily_balance_operations.prepareForecastForSameAmount(dailyBalances, minimumBalance, currentAverageDailyBalance)}');
    } else {
      input = input_utils_cli.getValidStringWithCustomInputsCli(
          'One Time Alteration => Immediate Withdraw (Just Enter), Immediate Deposit (Type OID), Timed Withdraw (OTW) or Timed Deposit (OTD) : ',
          ["", "OID", "OTW", "OTD"]);
      double amount = input_utils_cli.getValidDoubleCli('Enter amount : ');
      if (input == "") {
        print(
            'Forecast\n----------\n${daily_balance_operations.prepareForecastForOneTimeDifferentAmount(dailyBalances, minimumBalance, currentAverageDailyBalance, 0 - amount, isNotSameAmount: true)}');
      } else if (input == "OID") {
        print(
            'Forecast\n----------\n${daily_balance_operations.prepareForecastForOneTimeDifferentAmount(dailyBalances, minimumBalance, currentAverageDailyBalance, amount, isNotSameAmount: true)}');
      } else if (input == "OTW") {
        print(
            'Forecast\n----------\n${daily_balance_operations.prepareForecastForOneTimeDifferentAmount(dailyBalances, minimumBalance, currentAverageDailyBalance, 0 - amount, isNotTimedOperation: false, eventDate: input_utils_cli.getValidNormalGreaterDateCli(dailyBalances.keys.last))}');
      } else if (input == "OTD") {
        print(
            'Forecast\n----------\n${daily_balance_operations.prepareForecastForOneTimeDifferentAmount(dailyBalances, minimumBalance, currentAverageDailyBalance, amount, isNotTimedOperation: false, eventDate: input_utils_cli.getValidNormalGreaterDateCli(dailyBalances.keys.last))}');
      }
    }
  }
}
