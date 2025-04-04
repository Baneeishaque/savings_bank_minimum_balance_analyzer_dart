import 'dart:convert';

Map<String, List<TransactionAmountModel>> transactionAmountFromJson(
  String str,
) => Map.from(json.decode(str)).map(
  (k, v) => MapEntry<String, List<TransactionAmountModel>>(
    k,
    List<TransactionAmountModel>.from(
      v.map((x) => TransactionAmountModel.fromJson(x)),
    ),
  ),
);

String transactionAmountToJson(
  Map<DateTime, List<TransactionAmountModel>> data,
) => json.encode(
  Map.from(data).map(
    (k, v) => MapEntry<DateTime, dynamic>(
      k,
      List<dynamic>.from(v.map((x) => x.toJson())),
    ),
  ),
);

class TransactionAmountModel {
  TransactionAmountModel({required this.amount});

  num amount;

  factory TransactionAmountModel.fromJson(Map<String, dynamic> json) =>
      TransactionAmountModel(amount: json["amount"]);

  Map<String, dynamic> toJson() => {"amount": amount};
}
