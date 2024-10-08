// staff_model.dart

class Staff {
  final String id;
  final String username;
  final String name;
  final String email;
  final List<AssignedTrade> assignedTrades;
  final List<dynamic> paidTrades; // Assuming paidTrades might have a complex structure
  final String role;
  final bool clockedIn;
  final String? clockInTime;
  final String? clockOutTime;
  final List<DailyClockTime> dailyClockTimes; // New class for clock times
  final List<dynamic> payroll; // Assuming payroll might have a complex structure
  final List<dynamic> queries; // Assuming queries might have a complex structure
  final List<dynamic> messages; // Assuming messages might have a complex structure

  Staff({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.assignedTrades,
    required this.paidTrades,
    required this.role,
    required this.clockedIn,
    required this.clockInTime,
    required this.clockOutTime,
    required this.dailyClockTimes,
    required this.payroll,
    required this.queries,
    required this.messages,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    var tradeList = json['assignedTrades'] as List;
    List<AssignedTrade> trades = tradeList.map((i) => AssignedTrade.fromJson(i)).toList();

    var dailyClockList = json['dailyClockTimes'] as List;
    List<DailyClockTime> clockTimes = dailyClockList.map((i) => DailyClockTime.fromJson(i)).toList();

    return Staff(
      id: json['_id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      assignedTrades: trades,
      paidTrades: json['paidTrades'] ?? [],
      role: json['role'],
      clockedIn: json['clockedIn'],
      clockInTime: json['clockInTime'],
      clockOutTime: json['clockOutTime'],
      dailyClockTimes: clockTimes,
      payroll: json['payroll'] ?? [],
      queries: json['queries'] ?? [],
      messages: json['messages'] ?? [],
    );
  }
}

class AssignedTrade {
  final String account;
  final String amountPaid;
  final String assignedAt;
  final String fiatAmountRequested;
  final String handle;
  final bool isPaid;
  final String? markedAt; // Nullable for 'complain' status
  final String name;
  final String tradeHash;
  final String id; // Added field for trade ID

  AssignedTrade({
    required this.account,
    required this.amountPaid,
    required this.assignedAt,
    required this.fiatAmountRequested,
    required this.handle,
    required this.isPaid,
    required this.markedAt,
    required this.name,
    required this.tradeHash,
    required this.id,
  });

  factory AssignedTrade.fromJson(Map<String, dynamic> json) {
    return AssignedTrade(
      account: json['account'],
      amountPaid: json['amountPaid']?.toString() ?? 'N/A', // Handle null values
      assignedAt: json['assignedAt'],
      fiatAmountRequested: json['fiat_amount_requested'],
      handle: json['handle'],
      isPaid: json['isPaid'],
      markedAt: json['markedAt'], // Changed to be nullable
      name: json['name'],
      tradeHash: json['trade_hash'],
      id: json['_id'], // Added field for trade ID
    );
  }
}

class DailyClockTime {
  final String clockInTime;
  final String? clockOutTime;
  final String id; // Added field for daily clock time ID

  DailyClockTime({
    required this.clockInTime,
    required this.clockOutTime,
    required this.id,
  });

  factory DailyClockTime.fromJson(Map<String, dynamic> json) {
    return DailyClockTime(
      clockInTime: json['clockInTime'],
      clockOutTime: json['clockOutTime'],
      id: json['_id'], // Added field for daily clock time ID
    );
  }
}
