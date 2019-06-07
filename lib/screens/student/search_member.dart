import 'dart:ui';
import 'package:physique_gym/data/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:physique_gym/models/member_details.dart';

class SearchStudent extends StatefulWidget {
  SearchStudent() : super();

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchStudentState();
  }
}

class SearchStudentState extends State<SearchStudent> {
  String _phoneNumber;
  List<MemberDetails> _memebrs;
  BuildContext _ctx;
  var picture;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  bool _isLoading = false;

  void showMembers() async {
    var res = await getMemberDetails();
    setState(() {
      this._memebrs = res;
    });
  }

  Future<List<MemberDetails>> getMemberDetails() async {
    var db = new DatabaseHelper();
    List<MemberDetails> results = await db.retrieveMembers();
    return results;
  }


  void _submit() async {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();

    }
  }
  @override
  Widget build(BuildContext context) {

    var submitBtn = ButtonTheme(
        minWidth: 150.0,
        height: 30.0,
        child: RaisedButton(
          onPressed: _submit,
          child: new Text("SUBMIT"),
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
                      validator: (val) {
                        return val.length < 1
                            ? "Phone Number can not be blank."
                            : null;
                      },
                      decoration: new InputDecoration(labelText: "Phone Number"),
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
        appBar: null,
        body: new Container(
          child: new Container(
            child: new Center(
              child: new ClipRect(
                child: ListView(
                    children: <Widget>[searchStudentForm]
                ),
              ),
            ),
          ),
        ));

  }
}
