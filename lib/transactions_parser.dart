import 'dart:convert';

Map<String, List<TransactionAmountJson>> transactionsFromJson(String str) =>
    Map.from(json.decode(str)).map((k, v) =>
        MapEntry<String, List<TransactionAmountJson>>(
            k,
            List<TransactionAmountJson>.from(
                v.map((x) => TransactionAmountJson.fromJson(x)))));

String transactionsToJson(Map<DateTime, List<TransactionAmountJson>> data) =>
    json.encode(Map.from(data).map((k, v) => MapEntry<DateTime, dynamic>(
        k, List<dynamic>.from(v.map((x) => x.toJson())))));

class TransactionAmountJson {
  TransactionAmountJson({
    required this.amount,
  });

  num amount;

  factory TransactionAmountJson.fromJson(Map<String, dynamic> json) =>
      TransactionAmountJson(
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
      };
}
