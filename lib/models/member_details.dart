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
    StringBuffer memberString = new StringBuffer();
    memberString.write("First Name : ");
    memberString.write(_member.firstName);
    memberString.write(" , ");
    memberString.write("Last Name : ");
    memberString.write(_member.lastName);
    memberString.write(" , ");
    memberString.write("Phoner Number : ");
    memberString.write(_member.phoneNumber.toString());
    memberString.write("Address : ");
    memberString.write(_member.address);
    memberString.write(" , ");
    memberString.write("ID : ");
    memberString.write(_member.id.toString());
    memberString.write(" , ");
    memberString.write("Next Payment Date : ");
    memberString.write(nextPaymentDate);
    memberString.write(" :::::: Payment Details :::::: \n ");
    if (_memberPaymentHistoryList.length > 0) {
      int index = 1;
      for (MemberPaymentHistory paymentHistory in _memberPaymentHistoryList) {
        memberString.write("Payment ID :: " +
            index.toString() +
            " :: " +
            paymentHistory.paymentId.toString());
        memberString
            .write("Member ID :: " + paymentHistory.memberId.toString());
        memberString.write("Payment Date :: " +
            index.toString() +
            " :: " +
            paymentHistory.paymentDate);
        memberString.write("Payment Amount :: " +
            index.toString() +
            " :: " +
            paymentHistory.paymentAmount);
        index++;
      }
      memberString.write("\n");
    }
    return memberString.toString();
  }
}
