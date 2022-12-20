import 'package:savings_bank_minimum_balance_resolver_common/savings_bank_minimum_balance_resolver_common.dart'
    as savings_bank_minimum_balance_resolver_common;

void main(List<String> arguments) async {
  print(
      'Current Average Daily Balance: ${await savings_bank_minimum_balance_resolver_common.getCurrentAverageDailyBalanceFromCsv('dailyBalances.csv')}');
}
