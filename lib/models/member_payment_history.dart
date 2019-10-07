class MemberPaymentHistory {
  String _paymentAmount, _paymentDate;
  int _id, _paymentId;

  MemberPaymentHistory(this._paymentDate, this._paymentAmount);

  MemberPaymentHistory.map(dynamic obj) {
    this._paymentDate = obj["paymentDate"];
    this._paymentAmount = obj["paymentAmount"];
    this._id = obj["memberId"];
    this._paymentId = obj["id"];
  }

  set memberId(int id) => this._id = id;

  set paymentId(int paymentId) => this._paymentId = paymentId;

  int get paymentId => _paymentId;

  int get memberId => _id;

  String get paymentAmount => _paymentAmount;

  String get paymentDate => _paymentDate;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["paymentDate"] = _paymentDate;
    map["paymentAmount"] = _paymentAmount;
    map["memberId"] = _id;
    map["id"] = _paymentId;
    return map;
  }
}
