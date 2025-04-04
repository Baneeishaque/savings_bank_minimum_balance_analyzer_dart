import 'dart:convert';

TransactionsWithLastBalanceModel transactionsWithLastBalanceFromJson(
  String str,
) => TransactionsWithLastBalanceModel.fromJson(json.decode(str));

String transactionsWithLastBalanceToJson(
  TransactionsWithLastBalanceModel data,
) => json.encode(data.toJson());

class TransactionsWithLastBalanceModel {
  TransactionsWithLastBalanceModel({
    required this.lastBalance,
    required this.transactions,
  });

  LastBalance lastBalance;
  Map<String, List<num>> transactions;

  factory TransactionsWithLastBalanceModel.fromJson(
    Map<String, dynamic> json,
  ) => TransactionsWithLastBalanceModel(
    lastBalance: LastBalance.fromJson(json["lastBalance"]),
    transactions: Map.from(json["transactions"]).map(
      (k, v) => MapEntry<String, List<num>>(k, List<num>.from(v.map((x) => x))),
    ),
  );

  Map<String, dynamic> toJson() => {
    "lastBalance": lastBalance.toJson(),
    "transactions": Map.from(transactions).map(
      (k, v) =>
          MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x))),
    ),
  };
}

class LastBalance {
  LastBalance({required this.amount, required this.date});

  num amount;
  String date;

  factory LastBalance.fromJson(Map<String, dynamic> json) =>
      LastBalance(amount: json["amount"].toDouble(), date: json["date"]);

  Map<String, dynamic> toJson() => {"amount": amount, "date": date};

  @override
  String toString() {
    return 'LastBalance{amount: $amount, date: $date}';
  }
}
