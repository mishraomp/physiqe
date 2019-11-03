class Member {
  String _firstName,
      _lastName,
      _studentImage,
      _studentAddress,
      _nextPaymentDate;
  int _id, _phoneNumber;

  Member.memberWithArguments(this._firstName, this._lastName, this._phoneNumber, this._studentImage,
      this._nextPaymentDate, this._studentAddress);
  Member();

  set id(int id) => this._id = id;

  int get id => this._id;

  set firstName(String firstName) => this._firstName = firstName;

  String get firstName => this._firstName;

  set lastName(String lastName) => this._lastName = lastName;

  String get lastName => this._lastName;

  set phoneNumber(int phoneNumber) => this._phoneNumber = phoneNumber;

  int get phoneNumber => this._phoneNumber;

  set image(String image) => this._studentImage = image;

  String get image => this._studentImage;

  set address(String address) => this._studentAddress = address;

  String get address => this._studentAddress;

  set nextPaymentDate(String nextPaymentDate) =>
      this._nextPaymentDate = nextPaymentDate;

  String get nextPaymentDate => this._nextPaymentDate;

  Member.map(dynamic obj) {
    this._firstName = obj["firstName"];
    this._lastName = obj["lastName"];
    this._phoneNumber = obj["phoneNumber"];
    this._studentImage = obj["image"];
    this._nextPaymentDate = obj["nextPaymentDate"];
    this._studentAddress = obj["address"];
    this._id = obj["id"];
  }

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    map["firstName"] = _firstName;
    map["lastName"] = _lastName;
    map["phoneNumber"] = _phoneNumber;
    map["image"] = _studentImage;
    map["nextPaymentDate"] = _nextPaymentDate;
    map["address"] = _studentAddress;
    return map;
  }

  @override
  String toString() {
    String memberImage = _studentImage == null ? "" : _studentImage;
    String nextPaymentDate = _nextPaymentDate == null ? "" : _nextPaymentDate;
    String memberString = "First Name : " +
        _firstName +
        " , " +
        "Last Name : " +
        _lastName +
        " , " +
        "Phoner Number : " +
        _phoneNumber.toString() +
        " , " +
        "Address : " +
        _studentAddress == null ? "" : _studentAddress +
        " , " +
        "Image : " +
        memberImage +
        " , " +
        "Next Payment Date : " +
        nextPaymentDate;
    return memberString;
  }
}
