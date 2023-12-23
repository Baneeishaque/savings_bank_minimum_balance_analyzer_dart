import 'package:tuple/tuple.dart';

class Tuple4ForForecastWithSolutionForOneTimeAlteredBalanceModel
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

class Tuple5ForForecastForDaysWithSameBalanceAndOneTimeResolveModel
    extends Tuple5 {
  final double currentAverageDailyBalance;
  final double solutionAmount;
  final double repayAmount;
  final double paidAmount;
  final double advantageAmount;

  Tuple5ForForecastForDaysWithSameBalanceAndOneTimeResolveModel(
      this.currentAverageDailyBalance,
      this.solutionAmount,
      this.repayAmount,
      this.paidAmount,
      this.advantageAmount)
      : super(currentAverageDailyBalance, solutionAmount, repayAmount,
            paidAmount, advantageAmount);

  @override
  String toString() {
    return '[currentAverageDailyBalance => $currentAverageDailyBalance, solutionAmount => $solutionAmount, repayAmount => $repayAmount, paidAmount => $paidAmount, advantageAmount => $advantageAmount]';
  }
}
