import 'package:savings_bank_minimum_balance_resolver_common/daily_balance_operations_cli.dart'
    as daily_balance_operations_cli;

void main(List<String> arguments) async {
  print(
      'Average Daily Balance : ${await daily_balance_operations_cli.getCurrentAverageDailyBalanceFromTransactionsCsvCli('transactions.csv')}');
}
