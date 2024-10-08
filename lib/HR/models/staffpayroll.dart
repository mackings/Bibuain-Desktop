class StaffPayroll {
  final String id;
  final String name;
  final List<Payroll> payroll;

  StaffPayroll({
    required this.id,
    required this.name,
    required this.payroll,
  });

  factory StaffPayroll.fromJson(Map<String, dynamic> json) {
    var payrollList = json['payroll'] as List;
    List<Payroll> payrolls = payrollList.map((i) => Payroll.fromJson(i)).toList();

    return StaffPayroll(
      id: json['_id'],
      name: json['name'],
      payroll: payrolls,
    );
  }
}

class Payroll {
  final String id;  // _id from the payroll entry
  final String date;
  final double amount;
  final String month;
  final int year;
  final String level;
  final double basicSalary;
  final int daysOfWork;  // Added daysOfWork
  final double pay;
  final double incentives;
  final double debt;
  final double penalties;
  final double payables;
  final double savings;
  final double deductions;
  final double netSalary;

  Payroll({
    required this.id,
    required this.date,
    required this.amount,
    required this.month,
    required this.year,
    required this.level,
    required this.basicSalary,
    required this.daysOfWork,  // daysOfWork field
    required this.pay,
    required this.incentives,
    required this.debt,
    required this.penalties,
    required this.payables,
    required this.savings,
    required this.deductions,
    required this.netSalary,
  });

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['_id'],  // Extracting the _id field
      date: json['date'],
      amount: json['amount'].toDouble(),
      month: json['month'],
      year: json['year'],
      level: json['level'],
      basicSalary: json['basicSalary'].toDouble(),
      daysOfWork: json['daysOfWork'],  // Extracting daysOfWork
      pay: json['pay'].toDouble(),
      incentives: json['incentives'].toDouble(),
      debt: json['debt'].toDouble(),
      penalties: json['penalties'].toDouble(),
      payables: json['payables'].toDouble(),
      savings: json['savings'].toDouble(),
      deductions: json['deductions'].toDouble(),
      netSalary: json['netSalary'].toDouble(),
    );
  }
}
