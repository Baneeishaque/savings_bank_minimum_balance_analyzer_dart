import 'package:savings_bank_minimum_balance_resolver_common/daily_balance_operations.dart'
    as daily_balance_operations;

void main(List<String> arguments) async {
  print(
      'Daily Balances: ${await daily_balance_operations.calculateDailyBalancesFromTransactionsCsv('transactions.csv')}');
}
