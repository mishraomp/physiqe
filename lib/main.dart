import 'dart:async';

import 'package:flutter/material.dart';
import 'package:physique_gym/routes.dart';

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
    return new MaterialApp(
      title: 'Physique Gym',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: routes,
    );
  }
}
