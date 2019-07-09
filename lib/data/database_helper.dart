import 'dart:async';
import 'dart:io' as io;

import 'package:path/path.dart';
import 'package:physique_gym/models/member_details.dart';
import 'package:physique_gym/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:physique_gym/models/member.dart';
import 'package:physique_gym/models/member_payment_history.dart';
import 'package:physique_gym/constants/application_constants.dart';

class DatabaseHelper {
  final String createTableUser = ApplicationConstants.CREATE_TABLE +
      " " +
      ApplicationConstants.TABLE_USER +
      " (id INTEGER PRIMARY KEY, userName TEXT, password TEXT, firstName TEXT,lastName TEXT, phoneNumber INTEGER)";
  final String createTableMember = ApplicationConstants.CREATE_TABLE +
      " " +
      ApplicationConstants.TABLE_MEMBER +
      " (id INTEGER PRIMARY KEY, firstName TEXT, lastName TEXT, phoneNumber INTEGER, image TEXT, address TEXT, nextPaymentDate Date )";
  final String createTableMemberPaymentInfo = ApplicationConstants
          .CREATE_TABLE +
      " " +
      ApplicationConstants.TABLE_MEMBER_PAYMENT_INFO +
      " (id INTEGER PRIMARY KEY, memberId INTEGER NOT NULL, paymentDate TEXT, paymentAmount TEXT, FOREIGN KEY (memberId) REFERENCES " +
      ApplicationConstants.TABLE_MEMBER +
      " (id) )";
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
    await deleteDatabase(path);
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    try {
      await db.execute(createTableUser);
      await db.execute(createTableMember);
      await db.execute(createTableMemberPaymentInfo);
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

  Future<int> deleteMemberDetails() async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      await txn.delete(ApplicationConstants.TABLE_MEMBER_PAYMENT_INFO);
      await txn.delete(ApplicationConstants.TABLE_MEMBER);
    });

    return 1;
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
        var result =
            await txn.insert(ApplicationConstants.TABLE_MEMBER, member.toMap());
        paymentHistory.memberId = result;
        await txn.insert(ApplicationConstants.TABLE_MEMBER_PAYMENT_INFO,
            paymentHistory.toMap());
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<List<MemberDetails>> retrieveMembers(
      Map<String, String> queryMap) async {
    try {
      var dbClient = await db;
      List<MemberDetails> members = new List();
      String sql = buildSql(
          "SELECT * FROM " + ApplicationConstants.TABLE_MEMBER, queryMap);
      List<Map<String, dynamic>> results = await dbClient.rawQuery(sql);
      for (Map item in results) {
        List<MemberPaymentHistory> memberPaymentHistoryList = new List();
        Member member = Member.map(item);
        List<Map<String, dynamic>> memberPaymentDetails =
            await dbClient.rawQuery("SELECT * FROM " +
                ApplicationConstants.TABLE_MEMBER_PAYMENT_INFO +
                " where memberId=" +
                member.id.toString());
        for (Map memberPaymentDetails in memberPaymentDetails) {
          MemberPaymentHistory paymentHistory =
              MemberPaymentHistory.map(memberPaymentDetails);
          memberPaymentHistoryList.add(paymentHistory);
        }
        MemberDetails memberDetails =
            new MemberDetails(member, memberPaymentHistoryList);
        members.add(memberDetails);
      }
      return members;
    } catch (error) {
      print(error);
      return [];
    }
  }

  Future<int> addPaymentDetails(
      int memberId, DateTime paymentDate, int paymentAmount) async {
    try {
      var dbClient = await db;
      final MemberPaymentHistory paymentHistory = new MemberPaymentHistory(
          paymentDate.toString(), paymentAmount.toString());
      paymentHistory.memberId = memberId;
      await dbClient.transaction((txn) async {
        await txn.insert(ApplicationConstants.TABLE_MEMBER_PAYMENT_INFO,
            paymentHistory.toMap());
      });
      return 1;
    } catch (error) {
      print(error);
      return 0;
    }
  }

  Future<List<Member>> findMemberByPhoneNumber(int phoneNumber) async {
    try {
      List<Member> members = new List();
      var dbClient = await db;
      List<Map<String, dynamic>> results = await dbClient.rawQuery(
          "SELECT * FROM " +
              ApplicationConstants.TABLE_MEMBER +
              " where phoneNumber=" +
              phoneNumber.toString());
      for (var member in results) {
        members.add(Member.map(member));
      }
      return members;
    } catch (error) {
      print(error);
      return [];
    }
  }

  String buildSql(String sql, Map<String, String> queryMap) {
    if (queryMap == null) {
      return sql;
    } else {
      String whereClause = "";
      int index = 0;
      queryMap.forEach((key, value) => {
            if (index == 0)
              {whereClause = whereClause + " WHERE " + key + " = " + value}
            else
              {whereClause = whereClause + " AND " + key + " = " + value},
            index++
          });
      return sql + whereClause;
    }
  }
}
