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
    this.noOfDays,
  ) : super(currentAverageDailyBalance, solutionAmount, sumOfDailyBalances,
            noOfDays);

  @override
  String toString() {
    return '[currentAverageDailyBalance ($sumOfDailyBalances/$noOfDays) => $currentAverageDailyBalance, solutionAmount (($sumOfDailyBalances + $solutionAmount)/$noOfDays = minimumBalance) => $solutionAmount, sumOfDailyBalances => $sumOfDailyBalances, noOfDays => $noOfDays]';
  }
}

class Tuple7ForForecastForDaysWithSameBalanceAndOneTimeResolveModel
    extends Tuple7 {
  final double currentAverageDailyBalance;
  final double solutionAmount;
  final double repayAmount;
  final double paidAmount;
  final double advantageAmount;
  final double sumOfDailyBalances;
  final int noOfDays;

  Tuple7ForForecastForDaysWithSameBalanceAndOneTimeResolveModel(
    this.currentAverageDailyBalance,
    this.solutionAmount,
    this.repayAmount,
    this.paidAmount,
    this.advantageAmount,
    this.sumOfDailyBalances,
    this.noOfDays,
  ) : super(currentAverageDailyBalance, solutionAmount, repayAmount, paidAmount,
            advantageAmount, sumOfDailyBalances, noOfDays);

  @override
  String toString() {
    return '[currentAverageDailyBalance ($sumOfDailyBalances/$noOfDays) => $currentAverageDailyBalance, solutionAmount (($sumOfDailyBalances + $solutionAmount)/$noOfDays = minimumBalance) => $solutionAmount, repayAmount ((lastMinimumBalance + $solutionAmount) - minimumBalance) => $repayAmount, paidAmount => $paidAmount, advantageAmount (if $repayAmount != 0, then $repayAmount - previousPaidAmount) => $advantageAmount, sumOfDailyBalances => $sumOfDailyBalances, noOfDays => $noOfDays]';
  }
}
