import 'dart:convert';

TransactionsWithLastBalance transactionsWithLastBalanceFromJson(String str) =>
    TransactionsWithLastBalance.fromJson(json.decode(str));

String transactionsWithLastBalanceToJson(TransactionsWithLastBalance data) =>
    json.encode(data.toJson());

class TransactionsWithLastBalance {
  TransactionsWithLastBalance({
    required this.lastBalance,
    required this.transactions,
  });

  LastBalance lastBalance;
  Map<String, List<num>> transactions;

  factory TransactionsWithLastBalance.fromJson(Map<String, dynamic> json) =>
      TransactionsWithLastBalance(
        lastBalance: LastBalance.fromJson(json["lastBalance"]),
        transactions: Map.from(json["transactions"]).map((k, v) =>
            MapEntry<String, List<int>>(k, List<int>.from(v.map((x) => x)))),
      );

  Map<String, dynamic> toJson() => {
        "lastBalance": lastBalance.toJson(),
        "transactions": Map.from(transactions).map((k, v) =>
            MapEntry<String, dynamic>(k, List<dynamic>.from(v.map((x) => x)))),
      };
}

class LastBalance {
  LastBalance({
    required this.amount,
    required this.date,
  });

  num amount;
  String date;

  factory LastBalance.fromJson(Map<String, dynamic> json) => LastBalance(
        amount: json["amount"].toDouble(),
        date: json["date"],
      );

  Map<String, dynamic> toJson() => {
        "amount": amount,
        "date": date,
      };
}
