import 'package:grizzly_io/io_loader.dart';
import 'package:intl/intl.dart';
import 'package:savings_bank_minimum_balance_resolver_common/daily_balance.dart';
import 'package:savings_bank_minimum_balance_resolver_common/date_formats.dart';

double getCurrentAverageDailyBalance(
    double sumOfDailyBalances, int numberOfDays) {
  return sumOfDailyBalances / numberOfDays;
}

double getCurrentAverageDailyBalanceFromDailyBalanceList(
    List<DailyBalance> dailyBalances) {
  double sumOfDailyBalances = 0;
  for (DailyBalance dailyBalance in dailyBalances) {
    sumOfDailyBalances += dailyBalance.balance;
  }
  return getCurrentAverageDailyBalance(
      sumOfDailyBalances, dailyBalances.length);
}

Future<List<DailyBalance>> readDailyBalancesFromCsv(String csvPath) async {
  List<DailyBalance> dailyBalances = List.empty(growable: true);
  List<List<String>> dailyBalancesCsv = await readCsv(csvPath);
  for (List<String> row in dailyBalancesCsv) {
    dailyBalances.add(DailyBalance(
        date: DateFormat(DateFormats.normalDateFormat).parse(row[0]),
        balance: double.parse(row[1])));
  }
  return dailyBalances;
}

Future<double> getCurrentAverageDailyBalanceFromCsv(String csvPath) async {
  return getCurrentAverageDailyBalanceFromDailyBalanceList(
      await readDailyBalancesFromCsv(csvPath));
}
