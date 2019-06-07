import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:physique_gym/data/database_helper.dart';
import 'package:physique_gym/models/member.dart';
import 'package:physique_gym/models/member_payment_history.dart';

class AddStudent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddStudentState();
  }
}

class AddStudentState extends State<AddStudent> {
  String _firstName,
      _lastName,
      _phoneNumber,
      _studentImage,
      _studentAddress,
      _paymentAmount,
      _paymentDate,
      _nextPaymentDate;
  File _memberImage;
  BuildContext _ctx;
  var picture;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  bool _isLoading = false;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _memberImage = image;
    });
  }

  void _submit() async {
    final form = formKey.currentState;
    const base64 = const Base64Codec();
    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      bool memberExist =
          await new DatabaseHelper().memberExist(this._phoneNumber);
      if (!memberExist) {
        List<int> image =
            _memberImage != null ? await _memberImage.readAsBytes() : [];
        if (image.isNotEmpty) {
          String encodedImage = base64.encode(image);
          this._studentImage = encodedImage;
        }
        Member member = new Member(
            this._firstName,
            this._lastName,
            this._phoneNumber,
            this._studentImage,
            this._nextPaymentDate,
            this._studentAddress);
        MemberPaymentHistory paymentHistory =
            new MemberPaymentHistory(this._paymentDate, this._paymentAmount);
        var result =
            await new DatabaseHelper().addNewMember(member, paymentHistory);
        if (result) {
          setState(() {
            _isLoading = false;
            _memberImage = null;
            formKey.currentState.reset();
          });
          _showSnackBar("Member added successfully.", Colors.white);

        } else {
          _showSnackBar("Member could not be added.", Colors.red);
          setState(() => _isLoading = false);
        }
        print(result);
      } else {
        _showSnackBar(
            "Phoner Number is already used by another member.", Colors.red);
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String text, Color color) {
    Scaffold.of(_ctx).showSnackBar(SnackBar(
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
    final formats = {
      InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
      InputType.date: DateFormat('dd-MM-yyyy'),
      InputType.time: DateFormat("HH:mm"),
    };
    InputType inputType = InputType.date;
    var paymentDatePicker = DateTimePickerFormField(
      inputType: inputType,
      format: formats[inputType],
      initialValue: DateTime.now(),
      editable: false,
      onSaved: (val) => _paymentDate = val.toString(),
      validator: (val) {
        return val == null
            ? "Payment Date can not be blank."
            : null;
      },
      decoration: InputDecoration(
          labelText: 'Payment Date', hasFloatingPlaceholder: false),
      onChanged: (dt) => setState(() => date = dt),
    );
    var nextPaymentDatePicker = DateTimePickerFormField(
      inputType: inputType,
      format: formats[inputType],
      initialValue: DateTime.now().add(Duration(days: 30)),
      editable: false,
      onSaved: (val) => _nextPaymentDate = val.toString(),
      validator: (val) {
        return val == null
            ? "Next Payment Date can not be blank."
            : null;
      },
      decoration: InputDecoration(
          labelText: 'Next Payment Date', hasFloatingPlaceholder: false),
      onChanged: (dt) => setState(() => date = dt),
    );
    var submitBtn = ButtonTheme(
        minWidth: 150.0,
        height: 30.0,
        child: RaisedButton(
          onPressed: _submit,
          child: new Text("SUBMIT"),
          color: Colors.blue,
        ));
    var addStudentForm = new Container(
        child: new Column(
          children: <Widget>[
            new Text(
              "Add New Member",
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
                    child: _memberImage == null
                        ? FloatingActionButton(
                            onPressed: getImage,
                            tooltip: 'Add Image',
                            child: Icon(Icons.add_a_photo),
                          )
                        : Image.file(_memberImage),
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: new TextFormField(
                      onSaved: (val) => _firstName = val,
                      validator: (val) {
                        return val.length < 1
                            ? "First Name can not be blank."
                            : null;
                      },
                      decoration: new InputDecoration(labelText: "First Name"),
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: new TextFormField(
                      onSaved: (val) => _lastName = val,
                      validator: (val) {
                        return val.length < 1
                            ? "Last Name can not be blank."
                            : null;
                      },
                      decoration: new InputDecoration(labelText: "Last Name"),
                    ),
                  ),
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
                  new Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: new TextFormField(
                      onSaved: (val) => _studentAddress = val,
                      validator: (val) {
                        return val.length < 1
                            ? "Address can not be blank."
                            : null;
                      },
                      decoration: new InputDecoration(labelText: "Address"),
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
        height: 1200.0,
        width: 400.0,
        decoration:
            new BoxDecoration(color: Colors.grey.shade200.withOpacity(1)));

    return new Scaffold(
        appBar: null,
        key: scaffoldKey,
        body: new Container(
          child: new Container(
            child: new Center(
              child: new ClipRect(
                child: ListView(children: <Widget>[addStudentForm]),
              ),
            ),
          ),
        ));
  }
}
