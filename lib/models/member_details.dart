import 'package:physique_gym/models/member.dart';
import 'package:physique_gym/models/member_payment_history.dart';

class MemberDetails {
  Member _member;
  List<MemberPaymentHistory> _memberPaymentHistoryList;

  set memberDetails(Member member) {
    this._member = member;
  }

  MemberDetails(
      Member member, List<MemberPaymentHistory> memberPaymentHistoryList) {
    this._member = member;
    this._memberPaymentHistoryList = memberPaymentHistoryList;
  }

  Member get memberDetails => this._member;

  set memberPaymentDetails(
      List<MemberPaymentHistory> _memberPaymentHistoryList) {
    this._memberPaymentHistoryList = _memberPaymentHistoryList;
  }

  List<MemberPaymentHistory> get memberPaymentDetails =>
      this._memberPaymentHistoryList;

  @override
  String toString() {
    String memberImage = _member.image == null ? "" : _member.image;
    String nextPaymentDate =
        _member.nextPaymentDate == null ? "" : _member.nextPaymentDate;
    String memberString = "First Name : " +
        _member.firstName +
        " , " +
        "Last Name : " +
        _member.lastName +
        " , " +
        " , " +
        "Phoner Number : " +
        _member.phoneNumber +
        "Address : " +
        _member.address +
        " , " +
        "Image : " +
        memberImage +
        " , " +
        "Next Payment Date : " +
        nextPaymentDate;
    return memberString;
  }
}
