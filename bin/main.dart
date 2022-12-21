import 'package:savings_bank_minimum_balance_resolver_common/constants.dart'
    as constants;
import 'package:savings_bank_minimum_balance_resolver_common/daily_balance_operations.dart'
    as daily_balance_operations;
import 'package:savings_bank_minimum_balance_resolver_common/daily_balance_operations_cli.dart'
    as daily_balance_operations_cli;
import 'package:savings_bank_minimum_balance_resolver_common/input_utils_cli.dart'
    as input_utils_cli;

void main(List<String> arguments) async {
  int choice;
  do {
    print('1 : Calculate Average Balance from Daily Balances CSV : KGB');
    print('2 : Calculate Average Balance from Transactions CSV : KGB');
    print('3 : Calculate Average Balance from Daily Balances CSV : PNB');
    print('4 : Calculate Average Balance from Transactions CSV : PNB');
    print('0 : Exit');
    choice = input_utils_cli.getValidIntCli('Enter you choice : ');
    switch (choice) {
      case 1:
        print(
            'Average Daily Balance : ${await daily_balance_operations.getCurrentAverageDailyBalanceFromCsv('dailyBalances_kgb.csv')}');
        break;
      case 2:
        await invokeGetAverageBalanceFromTransactionsCsv(
            'transactions_kgb.csv', constants.kgbMinimumBalance);
        break;
      case 3:
        // print('Average Daily Balance : ${await daily_balance_operations
        //     .getCurrentAverageDailyBalanceFromCsv('dailyBalances_pnb.csv')}');
        break;
      case 4:
        // await invokeGetAverageBalanceFromTransactionsCsv(
        //     'transactions_pnb.csv', constants.pnbMinimumBalance);
        break;
      case 0:
        break;
      default:
        print('Invalid Option, Try again...');
    }
  } while (choice != 0);
}

Future<void> invokeGetAverageBalanceFromTransactionsCsv(
    String transactionCsv, double minimumBalance) async {
  Map<DateTime, double> dailyBalances = await daily_balance_operations_cli
      .calculateDailyBalancesFromTransactionsCsvCli(
          await daily_balance_operations
              .prepareTransactionSums(transactionCsv));
  double currentAverageDailyBalance = daily_balance_operations
      .getCurrentAverageDailyBalanceFromDailyBalanceMap(dailyBalances);
  int choice2;
  do {
    print('Average Daily Balance : $currentAverageDailyBalance');
    print('1 : Forecast with same amount');
    print('2 : Forecast with altered amount');
    print('0 : Exit');
    choice2 = input_utils_cli.getValidIntCli('Enter you choice : ');
    switch (choice2) {
      case 1:
        print('Forecast');
        print('----------');
        print(
            '${daily_balance_operations.prepareForecastForSameAmount(dailyBalances, minimumBalance, currentAverageDailyBalance)}');
        break;
      case 2:
        int choice3;
        do {
          print('1 : One Time Alteration - Immediate Withdraw');
          print('2 : One Time Alteration - Immediate Deposit');
          print('3 : One Time Alteration - Timed Withdraw');
          print('4 : One Time Alteration - Timed Deposit');
          print('0 : Exit');
          choice3 = input_utils_cli.getValidIntCli('Enter you choice : ');
          switch (choice3) {
            case 1:
              double amount =
                  input_utils_cli.getValidDoubleCli('Enter amount : ');
              print('Forecast');
              print('----------');
              print(
                  '${daily_balance_operations.prepareForecastForOneTimeDifferentAmount(dailyBalances, minimumBalance, currentAverageDailyBalance, 0 - amount, isNotSameAmount: true)}');
              break;
            case 2:
              // double amount =
              //     input_utils_cli.getValidDoubleCli('Enter amount : ');
              // print('Forecast');
              // print('----------');
              // print(
              //     '${daily_balance_operations.prepareForecastForOneTimeDifferentAmount(dailyBalances, minimumBalance, currentAverageDailyBalance, amount, isNotSameAmount: true)}');
              break;
            case 3:
              double amount =
                  input_utils_cli.getValidDoubleCli('Enter amount : ');
              print('Forecast');
              print('----------');
              print(
                  '${daily_balance_operations.prepareForecastForOneTimeDifferentAmount(dailyBalances, minimumBalance, currentAverageDailyBalance, 0 - amount, isNotTimedOperation: false, eventDate: input_utils_cli.getValidNormalGreaterDateCli(dailyBalances.keys.last))}');
              break;
            case 4:
              // double amount =
              //     input_utils_cli.getValidDoubleCli('Enter amount : ');
              // print('Forecast');
              // print('----------');
              // print(
              //     '${daily_balance_operations.prepareForecastForOneTimeDifferentAmount(dailyBalances, minimumBalance, currentAverageDailyBalance, amount, isNotTimedOperation: false, eventDate: input_utils_cli.getValidNormalGreaterDateCli(dailyBalances.keys.last))}');
              break;
            case 0:
              break;
            default:
              print('Invalid Option, Try again...');
          }
        } while (choice3 != 0);
        break;
      case 0:
        break;
      default:
        print('Invalid Option, Try again...');
    }
  } while (choice2 != 0);
}
