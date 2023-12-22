class TransactionModel {
  DateTime date = DateTime.now();
  double amount = 0;

  TransactionModel({
    required this.date,
    required this.amount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionModel &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          amount == other.amount);

  @override
  int get hashCode => date.hashCode ^ amount.hashCode;

  @override
  String toString() {
    return 'Transaction{ date: $date, amount: $amount,}';
  }

  TransactionModel copyWith({
    DateTime? date,
    double? amount,
  }) {
    return TransactionModel(
      date: date ?? this.date,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'amount': amount,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      date: map['date'] as DateTime,
      amount: map['amount'] as double,
    );
  }
}
