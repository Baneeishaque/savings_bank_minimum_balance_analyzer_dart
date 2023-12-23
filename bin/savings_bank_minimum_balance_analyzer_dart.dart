import 'package:jiffy/jiffy.dart';
import 'package:savings_bank_minimum_balance_analyzer_dart/constants.dart'
    as constants;
import 'package:savings_bank_minimum_balance_analyzer_dart/daily_balance_operations.dart'
    as daily_balance_operations;
import 'package:savings_bank_minimum_balance_analyzer_dart/daily_balance_operations_interactive.dart'
    as daily_balance_operations_interactive;
import 'package:savings_bank_minimum_balance_analyzer_dart/input_utils_interactive.dart'
    as input_utils_interactive;
import 'package:savings_bank_minimum_balance_analyzer_dart/models/daily_balance_model.dart';
import 'package:tuple/tuple.dart';

void main(List<String> arguments) async {
  int choice;
  do {
    print('1 : Calculate Average Balance from Daily Balances CSV : KGB');
    print('2 : Calculate Average Balance from Transactions CSV : KGB');
    print('3 : Calculate Average Balance from Daily Balances CSV : PNB');
    // print('4 : Calculate Average Balance from Transactions CSV : PNB');
    print('5 : Calculate Average Balance from Transactions JSON : KGB');
    print(
        '6 : Calculate Average Balance from Transactions with Last Balance JSON : KGB 1');
    // print(
    //     '7 : Calculate Average Balance from Transactions with Last Balance JSON (Up-to Yesterday) : KGB');
    print(
        '8 : Calculate Average Balance from Transactions with Last Balance JSON : KGB 2');
    print('0 : Exit');
    choice = input_utils_interactive.getValidIntCli('Enter you choice : ');
    switch (choice) {
      case 1:
        invokeForecast({
          for (DailyBalanceModel dailyBalance in (await daily_balance_operations
              .readDailyBalancesFromCsv('dailyBalances_kgb.csv')))
            dailyBalance.date: dailyBalance.balance
        }, constants.kgbMinimumBalance);
        // print(
        //     'Average Daily Balance : ${await daily_balance_operations.getCurrentAverageDailyBalanceFromCsv('dailyBalances_kgb.csv')}');
        break;
      case 2:
        await invokeGetAverageBalanceFromTransactionsCsv(
            'transactions_kgb.csv', constants.kgbMinimumBalance);
        break;
      case 3:
        invokeForecast({
          for (DailyBalanceModel dailyBalance in await daily_balance_operations
              .readDailyBalancesFromCsv('dailyBalances_pnb.csv'))
            dailyBalance.date: dailyBalance.balance
        }, constants.pnbMinimumBalance);
        break;
      // case 4:
      //   // await invokeGetAverageBalanceFromTransactionsCsv(
      //   //     'transactions_pnb.csv', constants.pnbMinimumBalance);
      //   break;
      case 5:
        invokeGetAverageBalanceFromTransactionsJson(
            'transactions_kgb.json', constants.kgbMinimumBalance);
        break;
      case 6:
        invokeForecast(
            daily_balance_operations_interactive
                .calculateDailyBalancesFromTransactionSumsWithLastBalanceCli(
                    daily_balance_operations
                        .prepareTransactionSumsWithLastBalanceFromJson(
                            'transactions_with_last_balance_kgb1.json')),
            constants.kgbMinimumBalance);
        break;
      // case 7:
      //   break;
      case 8:
        invokeForecast(
            daily_balance_operations_interactive
                .calculateDailyBalancesFromTransactionSumsWithLastBalanceCli(
                    daily_balance_operations
                        .prepareTransactionSumsWithLastBalanceFromJson(
                            'transactions_with_last_balance_kgb2.json')),
            constants.kgbMinimumBalance);
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
  invokeForecast(
      daily_balance_operations_interactive
          .calculateDailyBalancesFromTransactionSumsCli(
              await daily_balance_operations
                  .prepareTransactionSumsFromCsv(transactionCsv)),
      minimumBalance);
}

void invokeGetAverageBalanceFromTransactionsJson(
    String transactionJson, double minimumBalance) {
  invokeForecast(
      daily_balance_operations_interactive
          .calculateDailyBalancesFromTransactionSumsCli(daily_balance_operations
              .prepareTransactionSumsFromJson(transactionJson)),
      minimumBalance);
}

void invokeForecast(
    Map<DateTime, double> dailyBalances, double minimumBalance) {
  // Pair<averageDailyBalance, sumOfDailyBalances>
  Tuple2<double, double> averageDailyBalanceWithSum = daily_balance_operations
      .getAverageDailyBalanceAndSumFromDailyBalanceMap(dailyBalances);

  int choice2;
  do {
    print('Average Daily Balance : ${averageDailyBalanceWithSum.item1}');
    print('Required Minimum Daily Balance : $minimumBalance');

    print('1 : Forecast within minimum balance on same balance');
    print('2 : Forecast within minimum balance on altered balance');
    print('3 : Forecast for 5 days with same balance');
    print('4 : Forecast for 5 days with altered balance');
    // print('5 : Forecast for 5 days with same balance & one time resolve');
    print(
        '6 : Forecast for 5 days [with same balance & one time resolve (including repaying within minimum balance)]');
    print('7 : Forecast for 10 days with altered balance');
    print('8 : Forecast for 15 days with altered balance');
    print(
        '9 : Forecast for 10 days [with same balance & one time resolve (including repaying within minimum balance)]');
    print('10 : Forecast for 10 days with same balance');
    // print(
    //     '11 : Forecast for 10 days [with altered balance & one time resolve (including repaying within minimum balance)]');
    print(
        '12 : Forecast up-to month end [with same balance, one time resolve & next moment withdraw of resolve amount]');
    // print(
    //     '13 : Forecast up-to month end [with altered balance, one time resolve & next moment withdraw of resolve amount]');
    print('0 : Exit');
    choice2 = input_utils_interactive.getValidIntCli('Enter you choice : ');
    switch (choice2) {
      case 1:
        if (minimumBalance > averageDailyBalanceWithSum.item1) {
          print('Required Minimum Balance not resolved yet...');
        } else {
          print('Forecast');
          print('----------');
          print(
              '${daily_balance_operations.prepareForecastForSameBalance(dailyBalances, minimumBalance, averageDailyBalanceWithSum.item1)}');
        }
        break;
      case 2:
        if (minimumBalance > averageDailyBalanceWithSum.item1) {
          print('Required Minimum Balance not resolved yet...');
        } else {
          prepareForecastForAlteredBalance(
              dailyBalances, minimumBalance, averageDailyBalanceWithSum.item1);
        }
        break;
      case 3:
        print('Forecast');
        print('----------');
        print(
            '${daily_balance_operations.prepareForecastForDaysWithSameBalance(dailyBalances, minimumBalance, averageDailyBalanceWithSum.item1, 5)}');
        break;
      case 4:
        prepareForecastForAlteredBalance(
            dailyBalances, minimumBalance, averageDailyBalanceWithSum.item1,
            isForDays: true, forDays: 5);
        break;
      // case 5:
      //   break;
      case 6:
        print(
            '${daily_balance_operations_interactive.prepareForecastForDaysWithSameBalanceAndOneTimeResolve(dailyBalances, minimumBalance, averageDailyBalanceWithSum.item1, 5)}');
        break;
      case 7:
        prepareForecastForAlteredBalance(
            dailyBalances, minimumBalance, averageDailyBalanceWithSum.item1,
            isForDays: true, forDays: 10);
        break;
      case 8:
        prepareForecastForAlteredBalance(
            dailyBalances, minimumBalance, averageDailyBalanceWithSum.item1,
            isForDays: true, forDays: 15);
        break;
      case 9:
        print(
            '${daily_balance_operations_interactive.prepareForecastForDaysWithSameBalanceAndOneTimeResolve(dailyBalances, minimumBalance, averageDailyBalanceWithSum.item1, 10)}');
        break;
      case 10:
        print('Forecast');
        print('----------');
        print(
            '${daily_balance_operations.prepareForecastForDaysWithSameBalance(dailyBalances, minimumBalance, averageDailyBalanceWithSum.item1, 10)}');
        break;
      case 12:
        int lastDayOfMonth = Jiffy.now().daysInMonth;
        print(
            'Forecast for ${lastDayOfMonth == 31 ? '31 / 30' : lastDayOfMonth} days');
        print('------------------------');
        print(
            'Need to deposit ${((lastDayOfMonth == 31 ? 31 : lastDayOfMonth) * minimumBalance) - averageDailyBalanceWithSum.item2}');
        break;
      case 0:
        break;
      default:
        print('Invalid Option, Try again...');
    }
  } while (choice2 != 0);
}

void prepareForecastForAlteredBalance(Map<DateTime, double> dailyBalances,
    double minimumBalance, double currentAverageDailyBalance,
    {bool isForDays = false, int? forDays}) {
  int choice3;
  do {
    print('1 : One Time Alteration - Immediate Withdraw');
    // print('2 : One Time Alteration - Immediate Deposit');
    print('3 : One Time Alteration - Timed Withdraw');
    // print('4 : One Time Alteration - Timed Deposit');
    print('0 : Exit');
    choice3 = input_utils_interactive.getValidIntCli('Enter you choice : ');
    switch (choice3) {
      case 1:
        double amount =
            input_utils_interactive.getValidDoubleCli('Enter amount : ');
        print('Forecast');
        print('----------');
        if (isForDays) {
          print(
              '${daily_balance_operations.prepareForecastWithSolutionForOneTimeAlteredBalance(dailyBalances, minimumBalance, currentAverageDailyBalance, 0 - amount, isForDays: true, forDays: forDays)}');
        } else {
          print(
              '${daily_balance_operations.prepareForecastWithSolutionForOneTimeAlteredBalance(dailyBalances, minimumBalance, currentAverageDailyBalance, 0 - amount)}');
        }
        break;
      // case 2:
      //   break;
      case 3:
        double amount =
            input_utils_interactive.getValidDoubleCli('Enter amount : ');
        print('Forecast');
        print('----------');
        if (isForDays) {
          print(
              '${daily_balance_operations.prepareForecastWithSolutionForOneTimeAlteredBalance(dailyBalances, minimumBalance, currentAverageDailyBalance, 0 - amount, isNotTimedOperation: false, eventDate: input_utils_interactive.getValidNormalGreaterDateCli(dailyBalances.keys.last), isForDays: true, forDays: forDays)}');
        } else {
          print(
              '${daily_balance_operations.prepareForecastWithSolutionForOneTimeAlteredBalance(dailyBalances, minimumBalance, currentAverageDailyBalance, 0 - amount, isNotTimedOperation: false, eventDate: input_utils_interactive.getValidNormalGreaterDateCli(dailyBalances.keys.last))}');
        }
        break;
      // case 4:
      //   break;
      case 0:
        break;
      default:
        print('Invalid Option, Try again...');
    }
  } while (choice3 != 0);
}
