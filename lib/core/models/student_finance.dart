class PaymentRecord {
  final String id;
  final String studentId;
  final double amount;
  final DateTime paymentDate;
  final String referenceNo;

  PaymentRecord({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.paymentDate,
    required this.referenceNo,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id']?.toString() ?? '',
      studentId: json['student_id']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentDate: json['payment_date'] != null
          ? DateTime.tryParse(json['payment_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      referenceNo: json['reference_no']?.toString() ?? '',
    );
  }
}

class StudentFinanceSummary {
  final String studentId;
  final double totalFees;
  final double paidFees;
  final double remainingFees;
  final List<PaymentRecord> payments;

  StudentFinanceSummary({
    required this.studentId,
    required this.totalFees,
    required this.paidFees,
    required this.remainingFees,
    required this.payments,
  });

  factory StudentFinanceSummary.fromJson(Map<String, dynamic> json, List<dynamic> paymentsJson) {
    final tuition = json['tuition'] ?? json;
    
    final List<PaymentRecord> paymentRecords = paymentsJson
        .map((p) => PaymentRecord.fromJson(p))
        .toList();

    return StudentFinanceSummary(
      studentId: tuition['student_id']?.toString() ?? '',
      totalFees: double.tryParse(tuition['total_fees']?.toString() ?? '0') ?? 0.0,
      paidFees: double.tryParse(tuition['paid_fees']?.toString() ?? '0') ?? 0.0,
      remainingFees: double.tryParse(tuition['remaining_fees']?.toString() ?? '0') ?? 0.0,
      payments: paymentRecords,
    );
  }
}
