import 'dart:collection';

import 'package:savings_bank_minimum_balance_analyzer_dart/date_formats.dart';
import 'package:savings_bank_minimum_balance_analyzer_dart/models/tuple_for_forecast_model.dart';

class MapForForecastWithSolutionForOneTimeAlteredBalance<K, V> extends MapBase<
    DateTime, Tuple4ForForecastWithSolutionForOneTimeAlteredBalance> {
  final Map<DateTime, Tuple4ForForecastWithSolutionForOneTimeAlteredBalance>
      _map = LinkedHashMap<DateTime,
          Tuple4ForForecastWithSolutionForOneTimeAlteredBalance>.identity();

  @override
  Tuple4ForForecastWithSolutionForOneTimeAlteredBalance? operator [](
          Object? key) =>
      _map[key];

  @override
  void operator []=(DateTime key,
          Tuple4ForForecastWithSolutionForOneTimeAlteredBalance value) =>
      _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<DateTime> get keys => _map.keys;

  @override
  Tuple4ForForecastWithSolutionForOneTimeAlteredBalance? remove(Object? key) =>
      _map.remove(key);

  @override
  String toString() {
    String result = "{";
    for (int i = 0; i < _map.entries.length; i++) {
      MapEntry<DateTime, Tuple4ForForecastWithSolutionForOneTimeAlteredBalance>
          mapEntry = _map.entries.elementAt(i);
      if (i == 0) {
        result =
            "$result(Date => ${normalDateFormat.format(mapEntry.key)}: [${mapEntry.value.toString()}])";
      } else {
        result =
            "$result, (Date => ${normalDateFormat.format(mapEntry.key)}: [${mapEntry.value.toString()}])";
      }
    }
    return '$result}';
  }
}
