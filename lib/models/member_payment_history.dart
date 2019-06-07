class MemberPaymentHistory {
  String _paymentAmount, _paymentDate;
  int _id;

  MemberPaymentHistory(this._paymentDate, this._paymentAmount);

  MemberPaymentHistory.map(dynamic obj) {
    this._paymentDate = obj["paymentDate"];
    this._paymentAmount = obj["paymentAmount"];
    this._id = obj["studentId"];
  }

  set memberId(int id) => this._id = id;

  int get memberId => _id;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["paymentDate"] = _paymentDate;
    map["paymentAmount"] = _paymentAmount;
    map["studentId"] = _id;
    return map;
  }
}
