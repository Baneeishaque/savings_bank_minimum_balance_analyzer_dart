import 'package:tuple/tuple.dart';

class Tuple4ForForecastWithSolutionForOneTimeAlteredBalanceModel<T1, T2, T3, T4>
    extends Tuple4 {
  final double currentAverageDailyBalance;
  final double solutionAmount;
  final double sumOfDailyBalances;
  final int noOfDays;

  Tuple4ForForecastWithSolutionForOneTimeAlteredBalanceModel(
      this.currentAverageDailyBalance,
      this.solutionAmount,
      this.sumOfDailyBalances,
      this.noOfDays)
      : super(currentAverageDailyBalance, solutionAmount, sumOfDailyBalances,
            noOfDays);

  @override
  String toString() {
    return '[currentAverageDailyBalance => $currentAverageDailyBalance, solutionAmount => $solutionAmount, sumOfDailyBalances => $sumOfDailyBalances, noOfDays => $noOfDays]';
  }
}

class Tuple4ForForecastForDaysWithSameBalanceAndOneTimeResolveModel<T1, T2, T3,
    T4> extends Tuple4 {
  final double currentAverageDailyBalance;
  final double solutionAmount;
  final double repayAmount;
  final int dummy;

  Tuple4ForForecastForDaysWithSameBalanceAndOneTimeResolveModel(
      this.currentAverageDailyBalance,
      this.solutionAmount,
      this.repayAmount,
      this.dummy)
      : super(currentAverageDailyBalance, solutionAmount, repayAmount, dummy);

  @override
  String toString() {
    return '[currentAverageDailyBalance => $currentAverageDailyBalance, solutionAmount => $solutionAmount, repayAmount => $repayAmount, dummy => $dummy]';
  }
}
