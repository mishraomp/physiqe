import 'package:flutter/material.dart';
import 'package:physique_gym/screens/member/add_member.dart';
import 'package:physique_gym/screens/member/add_payment.dart';
import 'package:physique_gym/screens/member/search_member.dart';

enum UserAction { SEARCH, ADD, ADD_PAYMENT }

class HomeScreen extends StatefulWidget {
  HomeScreen() : super();

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomeScreen> {
  bool isSearchPageEnabled = false;
  bool isAddPageEnabled = false;
  bool isEditPageEnabled = false;
  bool isAddPaymentPageEnabled = false;
  bool isDeletePaymentPageEnabled = false;

  void setUserAction(UserAction action) {
    setState(() {
      if (action == UserAction.ADD) {
        isAddPageEnabled = true;
        isSearchPageEnabled = false;
        isAddPaymentPageEnabled = false;
        isEditPageEnabled = false;
        isDeletePaymentPageEnabled = false;
      } else if (action == UserAction.SEARCH) {
        isAddPageEnabled = false;
        isSearchPageEnabled = true;
        isAddPaymentPageEnabled = false;
        isEditPageEnabled = false;
        isDeletePaymentPageEnabled = false;
      } else if (action == UserAction.ADD_PAYMENT) {
        isAddPageEnabled = false;
        isSearchPageEnabled = false;
        isAddPaymentPageEnabled = true;
        isEditPageEnabled = false;
        isDeletePaymentPageEnabled = false;
      } else {
        isAddPageEnabled = false;
        isSearchPageEnabled = false;
        isAddPaymentPageEnabled = false;
        isEditPageEnabled = false;
        isDeletePaymentPageEnabled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text(
                "Home") /*,
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
        drawer: new Drawer(
            child: Container(
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
                        // setUserAction(UserAction.SEARCH);
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
                        // setUserAction(UserAction.ADD);
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
                        // setUserAction(UserAction.ADD);
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
                        // setUserAction(UserAction.ADD);
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddPayment(),
                            ));
                      },
                    )
                  ],
                ))),
        body: new Container(
          /*decoration: new BoxDecoration(
            image: new DecorationImage(
                image: new AssetImage("assets/images/background_image.jpg"),
                fit: BoxFit.cover),
          ),*/
          child: selectPageToDisplay(),
        ));
  }

  var welcome = new Text("Welcome to Physique Gym",
      style: new TextStyle(fontWeight: FontWeight.bold, color: Colors.blue));

  Widget selectPageToDisplay() {
    if (isAddPageEnabled) {
      return new AddMember();
    } else if (isSearchPageEnabled) {
      return new SearchMember();
    } else if (isAddPaymentPageEnabled) {
      return new AddPayment();
    } else {
      return new Container(
        child: new ClipRect(
          child: ListView(children: <Widget>[welcome, paymentDateList]),
        ),
      );
    }
  }

  var paymentDateList = new Container();
}
