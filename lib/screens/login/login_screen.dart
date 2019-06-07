import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:physique_gym/data/database_helper.dart';
import 'package:physique_gym/models/user.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  BuildContext _ctx;
  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  String _username, _password;

  void _submit() async {
    final form = formKey.currentState;

    if (form.validate()) {
      setState(() => _isLoading = true);
      form.save();
      var db = new DatabaseHelper();
      var user = await db.findUserByName(_username);
      if (user != null && user.password == _password) {
        User user = new User(_username, _password);
        onLoginSuccess(user);
      } else {
        onLoginError('Invalid Username or Password.');
      }
      // onLoginSuccess(new User(_username, _password));
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    _ctx = context;
    var loginBtn = ButtonTheme(
        minWidth: 150.0,
        height: 30.0,
        child: RaisedButton(
          onPressed: _submit,
          child: new Text("LOGIN"),
          color: Colors.blue,
        ));

    var loginForm = new Column(
      children: <Widget>[
        new Text(
          "Physique Gym App Login",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          textScaleFactor: 1.5,
        ),
        new Form(
          key: formKey,
          child: new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.all(4.0),
                child: new TextFormField(
                  onSaved: (val) => _username = val,
                  validator: (val) {
                    return val.length < 2
                        ? "Username must have atleast 2 characters."
                        : null;
                  },
                  decoration: new InputDecoration(labelText: "Username"),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(4.0),
                child: new TextFormField(
                  obscureText: true,
                  onSaved: (val) => _password = val,
                  validator: (val) {
                    return val.length < 1 ? "Password can not be blank." : null;
                  },
                  decoration: new InputDecoration(labelText: "Password"),
                ),
              ),
            ],
          ),
        ),
        _isLoading ? new CircularProgressIndicator() : loginBtn
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return new Scaffold(
      appBar: null,
      key: scaffoldKey,
      body: new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
              image: new AssetImage("assets/images/background_image.jpg"),
              fit: BoxFit.cover),
        ),
        child: new Center(
          child: new ClipRect(
            child: new BackdropFilter(
              filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: new Container(
                child: loginForm,
                height: 300.0,
                width: 300.0,
                decoration: new BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(1)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onLoginError(String errorTxt) {
    _showSnackBar(errorTxt);
    setState(() => _isLoading = false);
  }

  void onLoginSuccess(User user) async {
    //_showSnackBar(user.toString());
    setState(() => _isLoading = false);
    /*Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ));*/
    Navigator.of(_ctx).pushReplacementNamed("/home");
  }
}
