import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:physique_gym/data/database_helper.dart';
import 'package:physique_gym/models/member.dart';
import 'package:physique_gym/models/member_details.dart';
import 'package:physique_gym/models/member_payment_history.dart';

class ImportData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ImportDataState();
  }
}

class ImportDataState extends State<ImportData> {
  static Map<int, String> columnMap = new Map();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  bool _hasValidMime = false;
  FileType _pickingType = FileType.ANY;
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    if (_pickingType != FileType.CUSTOM || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        if (_multiPick) {
          _path = null;
          _paths = await FilePicker.getMultiFilePath(
              type: _pickingType, fileExtension: _extension);
        } else {
          _paths = null;
          _path = await FilePicker.getFilePath(
              type: _pickingType, fileExtension: _extension);
        }
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _fileName = _path != null
            ? _path.split('/').last
            : _paths != null ? _paths.keys.toString() : '...';
      });
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

  void _showSnackBarWithoutDuration(String text, Color color) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        text,
        style: TextStyle(color: color),
      ),
    ));
  }

  Future<String> readFromFile(String path) async {
    var db = new DatabaseHelper();
    File f = new File(path);
    var result = CsvToListConverter().convert(await f.readAsString());

    List<MemberDetails> memberDetailsList = new List();
    for (var element in result) {
      Member member = new Member();
      List<MemberPaymentHistory> memberPaymentHistoryList = new List();
      member.firstName = element[0];
      member.lastName = element[1];
      member.phoneNumber = element[2];
      member.image = element[3];
      member.nextPaymentDate = element[4];
      member.address = element[5];
      member.id = element[6];
      memberPaymentHistoryList = getPaymentHistoryFromString(element[7]);
      memberDetailsList
          .add(new MemberDetails(member, memberPaymentHistoryList));
/*      for(var el in element){

        var item = columnMapList[i];
        print(item.toString() + "::" + el.toString());
        i++;
      }*/

    }
    print(memberDetailsList);
    await db.addAllMemberDetails(memberDetailsList);
    return "success";
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: const Text('Import existing member data'),
      ),
      body: new Center(
          child: new Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: new SingleChildScrollView(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: new RaisedButton(
                  onPressed: () => _openFileExplorer(),
                  child: new Text("Select file to import data."),
                ),
              ),
              new Builder(
                builder: (BuildContext context) => _loadingPath
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: const CircularProgressIndicator())
                    : _path != null || _paths != null
                        ? new Container(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            height: MediaQuery.of(context).size.height * 0.50,
                            child: new Scrollbar(
                                child: new ListView.separated(
                              itemCount: _paths != null && _paths.isNotEmpty
                                  ? _paths.length
                                  : 1,
                              itemBuilder: (BuildContext context, int index) {
                                final bool isMultiPath =
                                    _paths != null && _paths.isNotEmpty;
                                final String name = 'File $index: ' +
                                    (isMultiPath
                                        ? _paths.keys.toList()[index]
                                        : _fileName ?? '...');
                                final path = isMultiPath
                                    ? _paths.values.toList()[index].toString()
                                    : _path;

                                return new ListTile(
                                  title: new Text(
                                    name,
                                  ),
                                  subtitle: new Text(path),
                                  onTap: () async {
                                    _showSnackBarWithoutDuration(
                                        "Data Import In Progress.",
                                        Colors.yellow);
                                    await readFromFile(path);
                                    _showSnackBar("Data Import is completed.",
                                        Colors.white);
                                    //Navigator.pushReplacementNamed(context, "/home");
                                  },
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      new Divider(),
                            )),
                          )
                        : new Container(),
              ),
            ],
          ),
        ),
      )),
    );
  }

  List<MemberPaymentHistory> getPaymentHistoryFromString(
      String paymentHistory) {
    List<MemberPaymentHistory> paymentHistoryList = new List();
    if (paymentHistory != null && paymentHistory.length > 0) {
      var paymentHistories = paymentHistory.split(",");
      for (String payment in paymentHistories) {
        MemberPaymentHistory memberPaymentHistory = new MemberPaymentHistory();
        var paymentHistoryDetails = payment.split("::");
        memberPaymentHistory.paymentId = int.parse(paymentHistoryDetails[0]);
        memberPaymentHistory.memberId = int.parse(paymentHistoryDetails[1]);
        memberPaymentHistory.paymentAmount = paymentHistoryDetails[2];
        memberPaymentHistory.paymentDate = paymentHistoryDetails[3];
        paymentHistoryList.add(memberPaymentHistory);
      }
    }

    return paymentHistoryList;
  }
}
