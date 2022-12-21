class Transaction {
  DateTime date = DateTime.now();
  double amount = 0;

//<editor-fold desc="Data Methods">
  Transaction({
    required this.date,
    required this.amount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          amount == other.amount);

  @override
  int get hashCode => date.hashCode ^ amount.hashCode;

  @override
  String toString() {
    return 'Transaction{ date: $date, amount: $amount,}';
  }

  Transaction copyWith({
    DateTime? date,
    double? amount,
  }) {
    return Transaction(
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

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      date: map['date'] as DateTime,
      amount: map['amount'] as double,
    );
  }

//</editor-fold>
}
