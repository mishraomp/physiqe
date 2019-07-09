import 'package:flutter/material.dart';
import 'package:physique_gym/screens/home/home_screen.dart';
import 'package:physique_gym/screens/login/login_screen.dart';
import 'package:physique_gym/screens/member/search_member.dart';
import 'package:physique_gym/screens/member/add_member.dart';

final routes = {
  '/login': (BuildContext context) => new LoginScreen(),
  '/home': (BuildContext context) => new HomeScreen(),
  '/': (BuildContext context) => new HomeScreen(),
  '/add': (BuildContext context) => new AddMember(),
  '/search': (BuildContext context) => new SearchMember()
};
