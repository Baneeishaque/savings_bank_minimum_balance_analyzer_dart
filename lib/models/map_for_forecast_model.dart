import 'dart:collection';

import 'package:savings_bank_minimum_balance_analyzer_dart/date_formats.dart';

class MapForForecastModel<K, V>
    extends MapBase<DateTime, V> {
  final Map<DateTime, V> _map = LinkedHashMap<DateTime, V>.identity();

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(DateTime key, V value) => _map[key] = value;

  @override
  void clear() => _map.clear();

  @override
  Iterable<DateTime> get keys => _map.keys;

  @override
  V? remove(Object? key) => _map.remove(key);

  @override
  String toString() {
    String result = "{";
    for (int i = 0; i < _map.entries.length; i++) {
      MapEntry<DateTime, V> mapEntry = _map.entries.elementAt(i);
      if (i == 0) {
        result =
            "$result(Date => ${normalDateFormat.format(mapEntry.key)}: \n${mapEntry.value.toString()})";
      } else {
        result =
            "$result, \n(Date => ${normalDateFormat.format(mapEntry.key)}: \n${mapEntry.value.toString()})";
      }
    }
    return '$result}';
  }
}
