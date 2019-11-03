import 'dart:ui';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physique_gym/data/database_helper.dart';
import 'package:physique_gym/models/member.dart';
import 'package:physique_gym/models/member_payment_history.dart';

class AddPayment extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddPaymentState();
  }
}

class AddPaymentState extends State<AddPayment> {
  String _paymentAmount, _paymentDate, _nextPaymentDate;
  int _phoneNumber;
  BuildContext _ctx;
  var picture;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  bool _isLoading = false;

  void _submit() async {
    final form = formKey.currentState;
    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      var members =
          await new DatabaseHelper().findMemberByPhoneNumber(this._phoneNumber);
      if (members.length == 0) {
        _showSnackBar("Phoner Number is not valid, please check with member.",
            Colors.red);
        setState(() => _isLoading = false);
      } else {
        Member member = members[0];
        member.nextPaymentDate = _nextPaymentDate;
        MemberPaymentHistory paymentHistory =
            new MemberPaymentHistory.withArguments(this._paymentDate, this._paymentAmount);
        var result =
            await new DatabaseHelper().addPaymentToExistingMember(member, paymentHistory);
        if (result) {
          setState(() {
            _isLoading = false;
            formKey.currentState.reset();
          });
          _showSnackBar("Payment Details added to Member: ${members[0].firstName} ${members[0].lastName} successfully.", Colors.white);
        } else {
          _showSnackBar("Payment Details could not be added.", Colors.red);
          setState(() => _isLoading = false);
        }
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
    // Obtain a list of the available cameras on the device.
    String validatePaymentAmount(val) {
      if (val.length < 1) {
        return "Payment Amount can not be blank.";
      } else {
        return null;
      }
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

    _ctx = context;
    DateTime date;
    var paymentDatePicker = DateTimeField(
      initialValue: DateTime.now(),
      readOnly: true,
      format: new DateFormat.yMMMMd("en_US"),
      onShowPicker: (context, currentValue) {
        return showDatePicker(
            context: context,
            firstDate: DateTime(2018),
            initialDate: DateTime.now(),
            lastDate: DateTime(2118));
      },
      onSaved: (val) => _paymentDate = val.toString(),
      validator: (val) {
        return val == null ? "Payment Date can not be blank." : null;
      },
      decoration: InputDecoration(
          labelText: 'Payment Date', hasFloatingPlaceholder: true),
      onChanged: (dt) => setState(() => date = dt),
    );
    var nextPaymentDatePicker = DateTimeField(
      readOnly: true,
      format: new DateFormat.yMMMMd("en_US"),
      initialValue: DateTime.now().add(Duration(days: 30)),
      onShowPicker: (context, currentVal) {
        return showDatePicker(
            context: context,
            firstDate: DateTime(2018),
            initialDate: currentVal ?? DateTime.now().add(Duration(days: 30)),
            lastDate: DateTime(2118));
      },
      onSaved: (val) => _nextPaymentDate = val.toString(),
      validator: (val) {
        return val == null ? "Next Payment Date can not be blank." : null;
      },
      decoration: InputDecoration(
          labelText: 'Next Payment Date', hasFloatingPlaceholder: true),
      onChanged: (dt) => setState(() => date = dt),
    );
    var submitBtn = ButtonTheme(
        minWidth: 150.0,
        height: 30.0,
        child: RaisedButton(
          onPressed: _submit,
          child: new Text("Add"),
          color: Colors.blue,
        ));
    var addPaymentForm = new SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: new Column(
        children: <Widget>[
          new Text(
            "Add Payment to Existing Member",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.blue),
            textScaleFactor: 1.5,
          ),
          new Form(
            key: formKey,
            child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: new TextFormField(
                    keyboardType: TextInputType.number,
                    onSaved: (val) => _phoneNumber = int.parse(val),
                    validator: validatePhoneNumber,
                    decoration: new InputDecoration(labelText: "Phone Number"),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: new TextFormField(
                    keyboardType: TextInputType.number,
                    onSaved: (val) => _paymentAmount = val,
                    validator: validatePaymentAmount,
                    decoration:
                        new InputDecoration(labelText: "Payment Amount"),
                  ),
                ),
                new Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: paymentDatePicker),
                new Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: nextPaymentDatePicker),
              ],
            ),
          ),
          _isLoading ? new CircularProgressIndicator() : submitBtn
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );

    return new Scaffold(
        appBar: new AppBar(
            title: new Text(
                "Add Payment") /*,
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child:
                  Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],*/
            ),
        key: scaffoldKey,
        body: new Container(
          child: new Container(
            child: new Center(
              child: new ClipRect(
                child: ListView(children: <Widget>[addPaymentForm]),
              ),
            ),
          ),
        ));
  }
}
