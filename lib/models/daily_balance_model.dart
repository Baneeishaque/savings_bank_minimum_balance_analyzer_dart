class DailyBalanceModel {
  DateTime date = DateTime.now();
  double balance = 0;

  DailyBalanceModel({required this.date, required this.balance});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyBalanceModel &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          balance == other.balance);

  @override
  int get hashCode => date.hashCode ^ balance.hashCode;

  @override
  String toString() {
    return 'DailyBalance{ date: $date, balance: $balance,}';
  }

  DailyBalanceModel copyWith({DateTime? date, double? balance}) {
    return DailyBalanceModel(
      date: date ?? this.date,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': date, 'balance': balance};
  }

  factory DailyBalanceModel.fromMap(Map<String, dynamic> map) {
    return DailyBalanceModel(
      date: map['date'] as DateTime,
      balance: map['balance'] as double,
    );
  }
}
