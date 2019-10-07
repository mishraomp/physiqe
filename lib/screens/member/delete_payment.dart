import 'dart:ui';
import 'package:physique_gym/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:physique_gym/models/member_details.dart';
import 'package:intl/intl.dart';
import 'package:physique_gym/models/member_payment_history.dart';

class DeleteMemberPayment extends StatefulWidget {
  DeleteMemberPayment() : super();

  @override
  State<StatefulWidget> createState() {
    return DeleteMemberPaymentState();
  }
}

class DeleteMemberPaymentState extends State<DeleteMemberPayment> {
  String _phoneNumber;
  List<MemberDetails> _members;
  List<MemberPaymentHistory> _selectedPayments;
  var picture;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    _selectedPayments = [];
    super.initState();
  }

  onSelectedRow(
      bool selected, MemberPaymentHistory memberPaymentHistory) async {
    setState(() {
      if (selected) {
        _selectedPayments.add(memberPaymentHistory);
      } else {
        _selectedPayments.remove(memberPaymentHistory);
      }
    });
  }

  deleteSelected() async {
      if (_selectedPayments.isNotEmpty) {
        List<MemberPaymentHistory> temp = [];
        temp.addAll(_selectedPayments);
        //make db call
        var db = new DatabaseHelper();
        var result = await db.deletePayments(temp);
        if (result) {
          setState(() {
            for (MemberPaymentHistory paymentHistory in temp) {
              this._members[0].memberPaymentDetails.remove(paymentHistory);
              _selectedPayments.remove(paymentHistory);
            }
          });
        }else {
          _showSnackBar("Could Not Delete The Records", Colors.red);
        }
      }
  }

  Future<List<MemberDetails>> getMemberDetails(Map queryMap) async {
    var db = new DatabaseHelper();
    List<MemberDetails> results = await db.retrieveMembers(queryMap);
    return results;
  }

  String validatePhoneNumber(val) {
    if (val.length < 1) {
      return "Phone Number can not be blank.";
    } else if (val.length != 10) {
      return "Phone Number should be 10 digit.";
    } else {
      return null;
    }
  }

  void _submit() async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
      Map<String, String> queryMap = {'phoneNumber': _phoneNumber};
      var res = await getMemberDetails(queryMap);
      setState(() {
        this._members = res;
      });
      if (this._members == null || this._members.length == 0) {
        _showSnackBar("Phoner Number is not mapped to any member.", Colors.red);
      }
    }
  }

  void _showSnackBar(String text, Color color) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        text,
        style: TextStyle(color: color),
      ),
      duration: Duration(seconds: 3),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var submitBtn = ButtonTheme(
        minWidth: 150.0,
        height: 30.0,
        child: RaisedButton(
          onPressed: _submit,
          child: new Text("Search"),
          color: Colors.blue,
        ));
    var searchStudentForm = new Container(
        child: SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new Form(
                key: formKey,
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: new TextFormField(
                        keyboardType: TextInputType.number,
                        onSaved: (val) => _phoneNumber = val,
                        validator: validatePhoneNumber,
                        decoration:
                            new InputDecoration(labelText: "Phone Number"),
                      ),
                    ),
                  ],
                ),
              ),
              _isLoading ? new CircularProgressIndicator() : submitBtn
            ],
            crossAxisAlignment: CrossAxisAlignment.center,
          ),
        ),
        height: 150,
        width: 400.0,
        decoration:
            new BoxDecoration(color: Colors.grey.shade200.withOpacity(1)));
    return new Scaffold(
        key: scaffoldKey,
        appBar:
            new AppBar(title: new Text("Delete Payment of Existing Member")),
        body: new Container(
          child: new Container(
            child: new Center(
              child: new ClipRect(
                child: ListView(
                    children: <Widget>[searchStudentForm, paymentSection()]),
              ),
            ),
          ),
        ));
  }

  paymentSection() {
    if (this._members == null || this._members.length == 0) {
      return new Container();
    }
    return ClipRect(
      child: Column(children: <Widget>[paymentHistory(), deletePaymentRow()]),
    );
  }

  Row deletePaymentRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20.0),
          child: OutlineButton(
            child: Text('Delete Selected Payment'),
            onPressed: _selectedPayments.isEmpty
                ? null
                : () {
                    deleteSelected();
                  },
          ),
        ),
      ],
    );
  }

  SingleChildScrollView paymentHistory() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: <Widget>[
        DataTable(
          columns: [
            DataColumn(
              label: Text("Payment Date"),
              numeric: false,
            ),
            DataColumn(
              label: Text("Payment Amount"),
              numeric: true,
            ),
          ],
          rows: this
              ._members[0]
              .memberPaymentDetails
              .map(
                (memberPaymentDetails) => DataRow(
                    selected: _selectedPayments.contains(memberPaymentDetails),
                    onSelectChanged: (b) {
                      print("Onselect");
                      onSelectedRow(b, memberPaymentDetails);
                    },
                    cells: [
                      DataCell(Text(new DateFormat.yMMMMd("en_US")
                          .format(
                              DateTime.parse(memberPaymentDetails.paymentDate))
                          .toString())),
                      DataCell(
                        Text(memberPaymentDetails.paymentAmount),
                        onTap: () {
                          print(
                              'Selected ${memberPaymentDetails.paymentAmount}');
                        },
                      )
                    ]),
              )
              .toList(),
        ),
      ]),
    );
  }
}
