import 'dart:async';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:physique_gym/data/database_helper.dart';
import 'package:physique_gym/models/member.dart';
import 'package:physique_gym/screens/data/import_data.dart';
import 'package:physique_gym/screens/member/add_member.dart';
import 'package:physique_gym/screens/member/add_payment.dart';
import 'package:physique_gym/screens/member/delete_payment.dart';
import 'package:physique_gym/screens/member/search_member.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen() : super();

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomeScreen> {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    // Add listeners to this class
    _isDataLoadedFromDB = false;

  }

  List<Member> _memberPaymentDueAsOfDateList;
  List<Member> _memberPaymentDueThisMonth;
  bool _isDataLoadedFromDB = false;

  void loadMemberDetails() async {
    var db = new DatabaseHelper();
    var paymentDueAsOfDate =
        await db.getAllMembersWithNextPaymentDateDueAsOfToday();
    var paymentDueCurrentMonth =
        await db.getAllMembersWithNextPaymentDateDueCurrentMonth();
    setState(() {
      _isDataLoadedFromDB = true;
      _memberPaymentDueAsOfDateList = paymentDueAsOfDate;
      _memberPaymentDueThisMonth = paymentDueCurrentMonth;
    });
  }

  void checkIfValueUpdatedInDB() async {
    var db = new DatabaseHelper();
    var paymentDueAsOfDate =
        await db.getAllMembersWithNextPaymentDateDueAsOfToday();
    var paymentDueCurrentMonth =
        await db.getAllMembersWithNextPaymentDateDueCurrentMonth();
    if (paymentDueAsOfDate.length != _memberPaymentDueAsOfDateList.length ||
        paymentDueCurrentMonth.length != _memberPaymentDueThisMonth.length) {
      setState(() {
        _isDataLoadedFromDB = true;
        _memberPaymentDueAsOfDateList = paymentDueAsOfDate;
        _memberPaymentDueThisMonth = paymentDueCurrentMonth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isDataLoadedFromDB) {
      loadMemberDetails();
    } else {
      checkIfValueUpdatedInDB();
    }
    var paymentDueAsOfDateList = (this._memberPaymentDueAsOfDateList == null ||
            this._memberPaymentDueAsOfDateList.length == 0)
        ? new Container()
        : Container(child: paymentDueAsOfDate());
    var paymentDueThisMonthList = (this._memberPaymentDueThisMonth == null ||
            this._memberPaymentDueThisMonth.length == 0)
        ? new Container()
        : Container(child: paymentDueThisMonth());
    var welcome = Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Text("Welcome to Physique Gym",
            style: new TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blue)));

    var paymentDueAsOfTodayMessage =
        (this._memberPaymentDueAsOfDateList == null ||
                this._memberPaymentDueAsOfDateList.length == 0)
            ? new Container()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: RichText(
                    text: TextSpan(
                        text: 'Payment Due Data',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            color: Colors.deepPurple,
                            fontSize: 14,
                            background: Paint()..color = Colors.blue[100]))));
    var paymentDueThisMonthMessage = (this._memberPaymentDueThisMonth == null ||
            this._memberPaymentDueThisMonth.length == 0)
        ? new Container()
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: RichText(
                text: TextSpan(
                    text: 'Upcoming Payment This Month',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.deepPurple,
                        fontSize: 14,
                        background: Paint()..color = Colors.blue[100]))));
    return new Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(title: new Text("Home")),
        endDrawer: Drawer(
            child: Container(
                width: 50,
                color: Colors.blue,
                child: ListView(
                  padding: EdgeInsets.all(10),
                  shrinkWrap: true,
                  children: <Widget>[
                    DrawerHeader(
                      child: new Text(
                        'File Upload',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                    ),
                    ListTile(
                      title: new Text(
                        'Import Data',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      onTap: () async {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImportData(),
                            ));
                       /* Navigator.of(context).pop();
                        _showSnackBarWithoutDuration(
                            "Data Import In Progress.", Colors.yellow);
                        await readFromFile();
                        _showSnackBar(
                            "Data Import is completed.", Colors.white);*/
                      },
                    ),
                    ListTile(
                      title: new Text(
                        'Export Data',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      onTap: () async {
                        Navigator.of(context).pop();
                        _showSnackBarWithoutDuration(
                            "Data Export In Progress.", Colors.yellow);
                        await writeDBDataToCSV();
                        _showSnackBar(
                            "Data Exported successfully.", Colors.white);
                      },
                    ),
                  ],
                ))),
        drawer: new Drawer(
            child: Container(
                width: 50,
                color: Colors.blue,
                child: ListView(
                  padding: EdgeInsets.all(10),
                  shrinkWrap: true,
                  children: <Widget>[
                    DrawerHeader(
                      child: new Text(
                        'Member Menu',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                    ),
                    ListTile(
                      title: new Text(
                        'Search',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchMember(),
                            ));
                      },
                    ),
                    ListTile(
                      title: new Text(
                        'Add',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddMember(),
                            ));
                      },
                    ),
                    ListTile(
                      title: new Text(
                        'Add Payment',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPayment(),
                            ));
                      },
                    ),
                    ListTile(
                      title: new Text(
                        'Delete Payment',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeleteMemberPayment(),
                            ));
                      },
                    )
                  ],
                ))),
        body: new Container(
          child: new ClipRect(
            child: ListView(children: <Widget>[
              welcome,
              paymentDueAsOfTodayMessage,
              paymentDueAsOfDateList,
              paymentDueThisMonthMessage,
              paymentDueThisMonthList
            ]),
          ),
        ));
  }

  SingleChildScrollView paymentDueAsOfDate() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: <Widget>[
              DataTable(
                columns: [
                  DataColumn(
                    label: Text("Name"),
                    numeric: false,
                  ),
                  DataColumn(
                    label: Text("Phone"),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text("Due Date"),
                    numeric: false,
                  ),
                ],
                rows: _memberPaymentDueAsOfDateList
                    .map(
                      (member) => DataRow(cells: [
                        DataCell(
                            Text(member.firstName + " " + member.lastName)),
                        DataCell(Text(member.phoneNumber.toString())),
                        DataCell(Text(new DateFormat.yMMMMd("en_US")
                            .format(DateTime.parse(member.nextPaymentDate))
                            .toString()))
                      ]),
                    )
                    .toList(),
              ),
            ])));
  }

  SingleChildScrollView paymentDueThisMonth() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(children: <Widget>[
            DataTable(
              dataRowHeight: 50,
              columns: [
                DataColumn(
                  label: Text("Name"),
                  numeric: false,
                ),
                DataColumn(
                  label: Text("Phone"),
                  numeric: true,
                ),
                DataColumn(
                  label: Text("Due Date"),
                  numeric: false,
                ),
              ],
              rows: _memberPaymentDueThisMonth
                  .map(
                    (member) => DataRow(cells: [
                      DataCell(Text(member.firstName + " " + member.lastName)),
                      DataCell(Text(member.phoneNumber.toString())),
                      DataCell(Text(new DateFormat.yMMMMd("en_US")
                          .format(DateTime.parse(member.nextPaymentDate))
                          .toString()))
                    ]),
                  )
                  .toList(),
            ),
          ]),
        ));
  }

  Future<String> writeDBDataToCSV() async {
    var db = new DatabaseHelper();
    var rows = await db.getAllMembers();
    var path = await getDocumentPath();
    writeToFile(path, rows);
    return "success";
  }

  Future<String> getDocumentPath() async {
    Directory documentsDirectory = await getExternalStorageDirectory();
    String path = join(documentsDirectory.path, "physique_gym_data");
    var directory = new Directory(path);
    if (!directory.existsSync()) {
      directory.create(recursive: true);
    }
    return path;
  }

  void writeToFile(String path, List<List<dynamic>> rows) async {
    path = path + "/physique_gym.csv";
    File f = new File(path);
    if (!await f.exists()) {
      f.createSync(recursive: true);
    }
    String csv = const ListToCsvConverter().convert(rows);
    f.writeAsString(csv);
    print("PATH is $path");
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

  void _showSnackBarWithoutDuration(String text, Color color) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        text,
        style: TextStyle(color: color),
      ),
    ));
  }
}
