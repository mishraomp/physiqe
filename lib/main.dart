import 'dart:async';

import 'package:flutter/material.dart';
import 'package:physique_gym/routes.dart';
import 'package:physique_gym/data/database_helper.dart';
import 'models/user.dart';

void main() => runApp(new PhysiqueGymApp());

class PhysiqueGymApp extends StatelessWidget {
  ImageCache get imageCache => PaintingBinding.instance.imageCache;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(hours: 12), (timer) {
      print(DateTime.now());
    });
    imageCache.clear();
    saveUser();
    return new MaterialApp(
      title: 'Physique Gym',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: routes,
    );
  }

  void saveUser() async {
    var db = new DatabaseHelper();
    //await db.deleteUsers();
    User user = new User('kc', 'kc123#');
    await db.saveUser(user);
  }
}
