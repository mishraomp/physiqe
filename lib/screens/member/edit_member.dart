import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:physique_gym/data/database_helper.dart';
import 'package:physique_gym/models/member.dart';
import 'package:physique_gym/models/member_details.dart';
import 'package:archive/archive.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditMember extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditMemberState();
  }
}

class EditMemberState extends State<EditMember> {
  List<MemberDetails> members;
  List<MemberDetails> membersOld;
  String _firstName,
      _lastName,
      _studentImage,
      _studentAddress,
      _nextPaymentDate;
  int _phoneNumber;
  File _memberImage;
  BuildContext _ctx;
  var picture;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  bool _isLoading = false;

  Future<List<int>> getCompressedImage(File file) async {
    if (file == null) {
      return [];
    }
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: 1920,
      minHeight: 1080,
      quality: 20,
      rotate: 0,
    );
    return result;
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    List<int> imageList = await getCompressedImage(image);
    if (imageList.isNotEmpty) {
      List<int> gzipBytes = new GZipEncoder().encode(imageList);
      String encodedImage = base64.encode(gzipBytes);
      setState(() {
        this.members[0].memberDetails.image = encodedImage;
      });
    }
  }

  void _submit() async {
    final form = formKey.currentState;
    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      if (isFormUpdated()) {
        var retrievedMembersByPhoneNumber = [];
        if (membersOld[0].memberDetails.phoneNumber != this._phoneNumber) {
          retrievedMembersByPhoneNumber = await new DatabaseHelper()
              .findMemberByPhoneNumber(this._phoneNumber);
        }
        if (retrievedMembersByPhoneNumber.length == 0) {
          if (this.members[0].memberDetails.image.isNotEmpty) {
            this._studentImage = this.members[0].memberDetails.image;
          }
          Member member = new Member(
              this._firstName,
              this._lastName,
              this._phoneNumber,
              this._studentImage,
              this._nextPaymentDate,
              this._studentAddress);
          member.id = this.members[0].memberDetails.id;
          var result = true;
          await new DatabaseHelper().updateMember(member);
          if (result) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar("Member updated successfully.", Colors.white);
          } else {
            _showSnackBar("Member could not be updated.", Colors.red);
            setState(() => _isLoading = false);
          }
        } else {
          _showSnackBar(
              "Phoner Number is already used by another member.${retrievedMembersByPhoneNumber[0].firstName + " " + retrievedMembersByPhoneNumber[0].lastName}",
              Colors.red);
          setState(() => _isLoading = false);
        }
      } else {
        _showSnackBar(
            "No updates made, please update before clicking on update.",
            Colors.red);
        setState(() => _isLoading = false);
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
    members = ModalRoute.of(context).settings.arguments;
    membersOld = ModalRoute.of(context)
        .settings
        .arguments; // assign it here for comparison during submit, if no updates to any field stop form submission.
    // Obtain a list of the available cameras on the device.

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

    var nextPaymentDatePicker = DateTimeField(
      readOnly: true,
      format: new DateFormat.yMMMMd("en_US"),
      initialValue: DateTime.now().add(Duration(days: 30)),
      onShowPicker: (context, currentVal) {
        return showDatePicker(
            context: context,
            firstDate: DateTime(2018),
            initialDate:
                DateTime.parse(this.members[0].memberDetails.nextPaymentDate) ??
                    DateTime.now().add(Duration(days: 30)),
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
          child: new Text("Update"),
          color: Colors.blue,
        ));
    var editMemberForm = new SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: new Column(
        children: <Widget>[
          new Text(
            "Edit Existing Member",
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
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: InkWell(
                      child: this.members[0].memberDetails.image == null
                          ? FloatingActionButton(
                              onPressed: getImage,
                              tooltip: 'Add Image',
                              child: Icon(Icons.add_a_photo),
                            )
                          : Image.memory(new GZipDecoder().decodeBytes(base64
                              .decode(this.members[0].memberDetails.image))),
                      onTap: getImage,
                    )),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: new TextFormField(
                    initialValue: this.members[0].memberDetails.firstName,
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
                    initialValue: this.members[0].memberDetails.lastName,
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
                    initialValue:
                        this.members[0].memberDetails.phoneNumber.toString(),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => _phoneNumber = int.parse(val),
                    validator: validatePhoneNumber,
                    decoration: new InputDecoration(labelText: "Phone Number"),
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: new TextFormField(
                    initialValue: this.members[0].memberDetails.address,
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
                "Edit") /*,
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
                child: ListView(children: <Widget>[editMemberForm]),
              ),
            ),
          ),
        ));
  }

  bool isFormUpdated() {
    final Member member = this.members[0].memberDetails;
    final Member memberOld = this.membersOld[0].memberDetails;
    if (member.nextPaymentDate != memberOld.nextPaymentDate) {
      return true;
    }
    if (this._firstName != memberOld.firstName) {
      return true;
    }
    if (this._lastName != memberOld.lastName) {
      return true;
    }
    if (this._phoneNumber != memberOld.phoneNumber) {
      return true;
    }
    if (member.image != memberOld.image) {
      return true;
    }
    if (this._studentAddress != memberOld.address) {
      return true;
    }
    return false;
  }
}
