import 'dart:ui';
import 'package:physique_gym/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:physique_gym/models/member_details.dart';
import 'package:physique_gym/screens/member/member_payment_history_details.dart';

class SearchMember extends StatefulWidget {
  SearchMember() : super();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchMemberState();
  }
}

class SearchMemberState extends State<SearchMember> {
  String _phoneNumber;
  List<MemberDetails> _memebrs;
  BuildContext _ctx;
  var picture;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  bool _isLoading = false;

  Future<List<MemberDetails>> getMemberDetails(Map queryMap) async {
    var db = new DatabaseHelper();
    List<MemberDetails> results = await db.retrieveMembers(queryMap);
   /* await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now(), 201);
    await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now().add(Duration(days: 1)), 202);
    await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now().add(Duration(days: 2)), 203);
    await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now().add(Duration(days: 3)), 204);
    await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now().add(Duration(days: 4)), 205);
    await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now().add(Duration(days: 5)), 206);
    await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now().add(Duration(days: 6)), 207);
    await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now().add(Duration(days: 7)), 208);
    await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now().add(Duration(days: 8)), 209);
    await db.addPaymentDetails(results[0].memberDetails.id, DateTime.now().add(Duration(days: 9)), 210);*/

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
      Map<String, String> queryMap = {'phoneNumber': _phoneNumber};
      var res = await getMemberDetails(queryMap);
      await
      setState(() {
        this._memebrs = res;
      });
      if (this._memebrs == null || this._memebrs.length == 0) {
        _showSnackBar("Phoner Number is not mapped to any member.", Colors.red);
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => new MemberPaymentHistoryDetails(),
                settings: RouteSettings(
                  arguments: this._memebrs
                )));
      }
    }
  }

  void _showSnackBar(String text, Color color) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        text,
        style: TextStyle(color: color),
      ),
      duration: Duration(seconds: 5),
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
        child: new Column(
          children: <Widget>[
            new Text(
              "Search Existing Member",
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
        height: 1200.0,
        width: 400.0,
        decoration:
            new BoxDecoration(color: Colors.grey.shade200.withOpacity(1)));
    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
            title: new Text(
                "Search") /*,
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
        body: new Container(
            child:
                searchStudentForm /* new Container(
            child: new Center(
              child: new ClipRect(
                child: ListView(children: <Widget>[searchStudentForm]),
              ),
            ),
          ),*/
            ));
  }
}
