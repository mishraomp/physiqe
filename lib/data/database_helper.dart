import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:physique_gym/models/member_details.dart';
import 'package:physique_gym/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:physique_gym/models/member.dart';
import 'package:physique_gym/models/member_payment_history.dart';

class DatabaseHelper {
  final String createTableUser =
      "CREATE TABLE user(id INTEGER PRIMARY KEY, userName TEXT, password TEXT, firstName TEXT,lastName TEXT, phoneNumber INTEGER)";
  final String createTableStudent =
      "CREATE TABLE student(id INTEGER PRIMARY KEY, studentFirstName TEXT, studentLastName TEXT, studentPhoneNumber TEXT, studentImage TEXT, studentAddress TEXT, nextPaymentDate Text)";
  final String createTableStudentPaymentInfo =
      "CREATE TABLE student_payment_info(id INTEGER PRIMARY KEY, studentId INTEGER NOT NULL, paymentDate TEXT, paymentAmount TEXT, FOREIGN KEY (studentId) REFERENCES student (id) )";
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "physique_gym.db");
    //await deleteDatabase(path);
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    try {
      await db.execute(createTableUser);
      await db.execute(createTableStudent);
      await db.execute(createTableStudentPaymentInfo);
    } catch (error) {
      print('Error occurred' + error);
    }
    print("Created tables");
  }

  Future<int> saveUser(User user) async {
    var dbClient = await db;
    List<Map<String, dynamic>> results = await dbClient
        .rawQuery("SELECT * FROM user where username ='" + user.username + "'");
    if (results.isEmpty) {
      return await dbClient.insert("User", user.toMap());
    }
    return 0;
  }

  Future<int> deleteUsers() async {
    var dbClient = await db;
    int res = await dbClient.delete("User");
    return res;
  }

  Future<bool> isLoggedIn() async {
    var dbClient = await db;
    var res = await dbClient.query("User");
    return res.length > 0 ? true : false;
  }

  Future<User> findUserByName(String userName) async {
    try {
      var dbClient = await db;
      List<Map> results = await dbClient
          .rawQuery("SELECT * FROM user where username ='" + userName + "'");
      User user = User.map(results.first);
      print(results);
      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addNewMember(
      final Member member, final MemberPaymentHistory paymentHistory) async {
    try {
      var dbClient = await db;
      await dbClient.transaction((txn) async {
        var result = await txn.insert('student', member.toMap());
        paymentHistory.memberId = result;
        await txn.insert('student_payment_info', paymentHistory.toMap());
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<List<MemberDetails>> retrieveMembers() async {
    try {
      var dbClient = await db;
      List<MemberDetails> members = new List();

      List<Map<String, dynamic>> results =
      await dbClient.rawQuery("SELECT * FROM student");
      for (Map item in results) {
        List<MemberPaymentHistory> memberPaymentHistoryList = new List();
        Member member = Member.map(item);
        List<Map<String, dynamic>> memberPaymentDetails = await dbClient
            .rawQuery("SELECT * FROM student_payment_info where studentId=" +
            member.id.toString() +
            "");
        for (Map memberPaymentDetails in memberPaymentDetails) {
          MemberPaymentHistory paymentHistory =
          MemberPaymentHistory.map(memberPaymentDetails);
          memberPaymentHistoryList.add(paymentHistory);
        }
        MemberDetails memberDetails =
        new MemberDetails(member, memberPaymentHistoryList);
        members.add(memberDetails);
      }
      print(members);
      return members;
    } catch (error) {
      return [];
    }
  }

  Future<bool> memberExist(String phoneNumber) async {
    try {
      var dbClient = await db;
      List<Map<String, dynamic>> results =
      await dbClient.rawQuery("SELECT * FROM student where studentPhoneNumber="+phoneNumber);

      print(results);
      return results.length > 0;
    } catch (error) {
      return false;
    }
  }
}
