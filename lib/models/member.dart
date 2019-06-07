class Member {
  String _firstName,
      _lastName,
      _phoneNumber,
      _studentImage,
      _studentAddress,
      _nextPaymentDate;
  int _id;

  Member(this._firstName, this._lastName, this._phoneNumber, this._studentImage,
      this._nextPaymentDate, this._studentAddress);

  set id(int id) => this._id = id;

  int get id => this._id;

  set firstName(String firstName) => this._firstName = firstName;

  String get firstName => this._firstName;

  set lastName(String lastName) => this._lastName = lastName;

  String get lastName => this._firstName;

  set phoneNumber(String phoneNumber) => this._phoneNumber = phoneNumber;

  String get phoneNumber => this._phoneNumber;

  set image(String image) => this._studentImage = image;

  String get image => this._studentImage;

  set address(String address) => this._studentAddress = address;

  String get address => this._studentAddress;

  set nextPaymentDate(String nextPaymentDate) =>
      this._nextPaymentDate = nextPaymentDate;

  String get nextPaymentDate => this._nextPaymentDate;

  Member.map(dynamic obj) {
    this._firstName = obj["studentFirstName"];
    this._lastName = obj["studentLastName"];
    this._phoneNumber = obj["studentPhoneNumber"];
    this._studentImage = obj["studentImage"];
    this._nextPaymentDate = obj["nextPaymentDate"];
    this._studentAddress = obj["studentAddress"];
    this._id = obj["id"];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["studentFirstName"] = _firstName;
    map["studentLastName"] = _lastName;
    map["studentPhoneNumber"] = _phoneNumber;
    map["studentImage"] = _studentImage;
    map["nextPaymentDate"] = _nextPaymentDate;
    map["studentAddress"] = _studentAddress;
    return map;
  }
}
