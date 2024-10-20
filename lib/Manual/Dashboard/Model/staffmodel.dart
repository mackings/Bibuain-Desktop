class StaffResponse {
  final bool success;
  final String message;
  final StaffData data;

  StaffResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StaffResponse.fromJson(Map<String, dynamic> json) {
    return StaffResponse(
      success: json['success'],
      message: json['message'],
      data: StaffData.fromJson(json['data']),
    );
  }
}

class StaffData {
  final String id; // Corresponds to _id
  final String username;
  final String name;
  final String email;
  final String role;
  final bool clockedIn;
  final List<ClockTime> dailyClockTimes;
  final List<AssignedTrade> assignedTrades;
  final List<dynamic> paidTrades; // Adjusted to match the API response
  final List<dynamic> payroll; // Adjusted to match the API response
  final List<dynamic> queries; // Added missing details
  final List<dynamic> messages; // Added missing details
  final String? clockInTime; // Can be null
  final String? clockOutTime; // Can be null

  StaffData({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    required this.clockedIn,
    required this.dailyClockTimes,
    required this.assignedTrades,
    required this.paidTrades, // Added
    required this.payroll, // Added
    required this.queries, // Added
    required this.messages, // Added
    this.clockInTime, // Can be null
    this.clockOutTime, // Can be null
  });

  factory StaffData.fromJson(Map<String, dynamic> json) {
    var clockTimes = (json['dailyClockTimes'] as List)
        .map((e) => ClockTime.fromJson(e))
        .toList();

    var trades = (json['assignedTrades'] as List)
        .map((e) => AssignedTrade.fromJson(e))
        .toList();

    return StaffData(
      id: json['_id'],
      username: json['username'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      clockedIn: json['clockedIn'],
      dailyClockTimes: clockTimes,
      assignedTrades: trades,
      paidTrades: json['paidTrades'] ?? [], // Adjusted
      payroll: json['payroll'] ?? [], // Adjusted
      queries: json['queries'] ?? [], // Added
      messages: json['messages'] ?? [], // Added
      clockInTime: json['clockInTime'], // Can be null
      clockOutTime: json['clockOutTime'], // Can be null
    );
  }
}

class ClockTime {
  final String clockInTime;
  final String? clockOutTime;
  final String id;

  ClockTime({
    required this.clockInTime,
    this.clockOutTime,
    required this.id,
  });

  factory ClockTime.fromJson(Map<String, dynamic> json) {
    return ClockTime(
      clockInTime: json['clockInTime'],
      clockOutTime: json['clockOutTime'],
      id: json['_id'],
    );
  }
}

class AssignedTrade {
  final String account;
  final String? amountPaid; // Can be null
  final String assignedAt;
  final String fiatAmountRequested; // Corrected to match API
  final String handle;
  final bool isPaid;
  final String? markedAt; // Can be null
  final String name;
  final String tradeHash;
  final String id;

  AssignedTrade({
    required this.account,
    this.amountPaid,
    required this.assignedAt,
    required this.fiatAmountRequested,
    required this.handle,
    required this.isPaid,
    this.markedAt, // Adjusted
    required this.name,
    required this.tradeHash,
    required this.id,
  });

  factory AssignedTrade.fromJson(Map<String, dynamic> json) {
    return AssignedTrade(
      account: json['account'],
      amountPaid: json['amountPaid'], // Can be null
      assignedAt: json['assignedAt'],
      fiatAmountRequested: json['fiat_amount_requested'], // Corrected to match API
      handle: json['handle'],
      isPaid: json['isPaid'],
      markedAt: json['markedAt'], // Can be null
      name: json['name'],
      tradeHash: json['trade_hash'],
      id: json['_id'],
    );
  }
}
