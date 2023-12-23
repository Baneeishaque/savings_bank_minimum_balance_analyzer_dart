import 'package:tuple/tuple.dart';

class Tuple4ForForecastWithSolutionForOneTimeAlteredBalance<T1, T2, T3, T4>
    extends Tuple4 {
  //[currentAverageDailyBalance, solutionAmount, sumOfDailyBalancesForExtraOneDay, noOfDays]
  Tuple4ForForecastWithSolutionForOneTimeAlteredBalance(
      super.item1, super.item2, super.item3, super.item4);

  @override
  String toString() {
    return '[currentAverageDailyBalance => $item1, solutionAmount => $item2, sumOfDailyBalances => $item3, noOfDays => $item4]';
  }
}
