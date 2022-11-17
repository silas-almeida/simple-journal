import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_journal/services/webclient.dart';

class AuthService {
  String url = WebClient.url;
  http.Client client = WebClient.client;
  

  Future<bool> login({required String email, required String password}) async {
    http.Response response = await client.post(
      Uri.parse("${url}login"),
      body: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode != 200) {
      final String content = json.decode(response.body);
      switch (content) {
        case "Cannot find user":
          throw UserNotFindException();
      }
      throw HttpException(response.body);
    }
    saveUserInfos(response.body);
    return Future.value(true);
  }

  Future<bool> register(
      {required String email, required String password}) async {
    http.Response response = await client.post(
      Uri.parse("${url}register"),
      body: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode != 201) {
      throw HttpException(response.body);
    }
    saveUserInfos(response.body);
    return Future.value(true);
  }

  Future<void> saveUserInfos(String body) async {
    final Map<String, dynamic> map = json.decode(body);
    final String token = map["accessToken"];
    final String email = map["user"]["email"];
    final int id = map["user"]["id"];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("accessToken", token);
    prefs.setString("email", email);
    prefs.setInt("id", id);    
  }

  void clearUserInfo() {
    SharedPreferences.getInstance().then((prefs) => prefs.clear());
  }
}

class UserNotFindException implements Exception {}
