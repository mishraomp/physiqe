import 'package:flutter/material.dart';
import 'package:physique_gym/models/member_details.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:archive/archive.dart';
import 'package:physique_gym/screens/member/edit_member.dart';

class MemberPaymentHistoryDetails extends StatefulWidget {
  final List<MemberDetails> members;

  MemberPaymentHistoryDetails({Key key, @required this.members})
      : super(key: key);

  final String title = "Member and Payment Details";

  @override
  MemberPaymentHistoryDetailsState createState() =>
      MemberPaymentHistoryDetailsState();
}

class MemberPaymentHistoryDetailsState
    extends State<MemberPaymentHistoryDetails> {
  double height;
  List<MemberDetails> members;
  List<MemberDetails> selectedUsers;
  bool sort;

  @override
  void initState() {
    sort = false;
    selectedUsers = [];
    super.initState();
  }

/*  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        users.sort((a, b) => a.firstName.compareTo(b.firstName));
      } else {
        users.sort((a, b) => b.firstName.compareTo(a.firstName));
      }
    }
  }*/

  onSelectedRow(bool selected, MemberDetails member) async {
    setState(() {
      if (selected) {
        selectedUsers.add(member);
      } else {
        selectedUsers.remove(member);
      }
    });
  }

  deleteSelected() async {
    setState(() {
      if (selectedUsers.isNotEmpty) {
        List<MemberDetails> temp = [];
        temp.addAll(selectedUsers);
        for (MemberDetails member in temp) {
          members.remove(member);
          selectedUsers.remove(member);
        }
      }
    });
  }

  SingleChildScrollView dataBody() {
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(children: <Widget>[
            DataTable(
              horizontalMargin: 10,
              columns: [
                DataColumn(
                  label: Text("First Name"),
                  numeric: false,
                  tooltip: "This is First Name",
                ),
                DataColumn(
                  label: Text("Last Name"),
                  numeric: false,
                  tooltip: "This is Last Name",
                ),
                DataColumn(
                  label: Text("Phone Number"),
                  numeric: true,
                  tooltip: "This is Phone Number",
                ),
                DataColumn(
                  label: Text("Next Payment Date"),
                  numeric: false,
                  tooltip: "Next Payment Date",
                ),
              ],
              rows: members
                  .map(
                    (member) => DataRow(
                        /*selected: selectedUsers.contains(member),
                        onSelectChanged: (b) {
                          onSelectedRow(b, member);
                        },*/
                        cells: [
                          DataCell(
                            Text(member.memberDetails.firstName),
                            onTap: () {

                            },
                          ),
                          DataCell(
                            Text(member.memberDetails.lastName),
                          ),
                          DataCell(
                            Text(member.memberDetails.phoneNumber.toString()),
                          ),
                          DataCell(
                            Text(new DateFormat.yMMMMd("en_US")
                                .format(DateTime.parse(
                                    member.memberDetails.nextPaymentDate))
                                .toString()),
                          ),
                        ]),
                  )
                  .toList(),
            ),
          ]),
        ));
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
          rows: members[0]
              .memberPaymentDetails
              .map(
                (memberPaymentDetails) => DataRow(cells: [
                  DataCell(Text(new DateFormat.yMMMMd("en_US")
                      .format(DateTime.parse(memberPaymentDetails.paymentDate))
                      .toString())),
                  DataCell(
                    Text(memberPaymentDetails.paymentAmount),
                    onTap: () {
                    },
                  )
                ]),
              )
              .toList(),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    const base64 = const Base64Codec();
    members = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            verticalDirection: VerticalDirection.down,
            children: <Widget>[
              Expanded(
                  child: Padding(
                padding: EdgeInsets.all(2.0),
                child: members[0].memberDetails.image != null
                    ? Image.memory(
                        new GZipDecoder().decodeBytes(
                            base64.decode(members[0].memberDetails.image)),
                      )
                    : null,
              )),
              Expanded(
                child: dataBody(),
              ),
              Expanded(
                child: paymentHistory(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: OutlineButton(
                      child: Text('Edit Member'),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => new EditMember(),
                                settings:
                                    RouteSettings(arguments: this.members)));
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: OutlineButton(
                      child: Text('Delete Member'),
                      onPressed: () {
                        _asyncConfirmDialog(context);
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

enum ConfirmAction { CANCEL, ACCEPT }

Future<ConfirmAction> _asyncConfirmDialog(BuildContext context) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false, // user must tap button for close dialog!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('DELETE MEMBER?'),
        content: const Text('This will delete the member.'),
        actions: <Widget>[
          FlatButton(
            child: const Text('YES'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          ),
          FlatButton(
            child: const Text('NO'),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          )
        ],
      );
    },
  );
}
