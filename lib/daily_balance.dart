class DailyBalance {
  DateTime date = DateTime.now();
  double balance = 0;

//<editor-fold desc="Data Methods">
  DailyBalance({
    required this.date,
    required this.balance,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyBalance &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          balance == other.balance);

  @override
  int get hashCode => date.hashCode ^ balance.hashCode;

  @override
  String toString() {
    return 'DailyBalance{ date: $date, balance: $balance,}';
  }

  DailyBalance copyWith({
    DateTime? date,
    double? balance,
  }) {
    return DailyBalance(
      date: date ?? this.date,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'balance': balance,
    };
  }

  factory DailyBalance.fromMap(Map<String, dynamic> map) {
    return DailyBalance(
      date: map['date'] as DateTime,
      balance: map['balance'] as double,
    );
  }
//</editor-fold>
}
