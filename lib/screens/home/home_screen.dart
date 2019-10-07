import 'package:flutter/material.dart';
import 'package:physique_gym/models/member.dart';
import 'package:physique_gym/screens/member/add_member.dart';
import 'package:physique_gym/screens/member/add_payment.dart';
import 'package:physique_gym/screens/member/delete_payment.dart';
import 'package:physique_gym/screens/member/search_member.dart';
import 'package:intl/intl.dart';
import 'package:physique_gym/data/database_helper.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen() : super();

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomeScreen> {
  HomePageState() {
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
    var paymentDueAsOfDateList = this._memberPaymentDueAsOfDateList == null
        ? new Container()
        : Container(child: paymentDueAsOfDate());
    var paymentDueThisMonthList = this._memberPaymentDueThisMonth == null
        ? new Container()
        : Container(child: paymentDueThisMonth());
    var welcome = Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Text("Welcome to Physique Gym",
            style: new TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blue)));

    var paymentDueAsOfTodayMessage = this._memberPaymentDueAsOfDateList == null
        ? new Container()
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: new Text("Payment Due Data:",
                style: new TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red)));
    var paymentDueThisMonthMessage = this._memberPaymentDueThisMonth == null
        ? new Container()
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: new Text("Upcoming Payment:",
                style: new TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.green)));
    return new Scaffold(
        appBar: new AppBar(title: new Text("Home")),
        drawer: new Drawer(
            child: Container(
                width: 50,
                color: Colors.blue,
                child: ListView(
                  padding: EdgeInsets.all(10),
                  shrinkWrap: true,
                  children: <Widget>[
                    new DrawerHeader(
                      child: new Text(
                        'Member Menu',
                        style: TextStyle(
                            color: Colors.white, fontStyle: FontStyle.italic),
                      ),
                    ),
                    new ListTile(
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
                    new ListTile(
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
                    new ListTile(
                      title: new Text(
                        'Edit',
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
                    new ListTile(
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
                    new ListTile(
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
              rows: _memberPaymentDueAsOfDateList
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
}
