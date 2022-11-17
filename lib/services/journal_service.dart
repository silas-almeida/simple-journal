import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:simple_journal/services/webclient.dart';

import '../models/journal.dart';

class JournalService {
  static const String resource = "journals/";

  String url = WebClient.url;
  http.Client client = WebClient.client;

  String getUrl() {
    return "$url$resource";
  }

  Future<bool> register(
      {required Journal journal, required String token}) async {
    String jsonJournal = jsonEncode(journal.toMap());
    http.Response response = await client.post(
      Uri.parse(getUrl()),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonJournal,
    );
    if (response.statusCode != 201) {
      if (json.decode(response.body) == "jwt expired") {
        throw InvalidTokenException();
      }
      throw HttpException(response.body);
    }
    return true;
  }

  Future<List<Journal>> getAll({
    required String id,
    required String token,
  }) async {
    final http.Response response = await client.get(
        Uri.parse("${url}users/$id/journals"),
        headers: {"Authorization": "Bearer $token"});
    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw InvalidTokenException();
      }
      throw HttpException(response.body);
    }
    List<Journal> journalsList = [];

    final List<dynamic> jsonList = jsonDecode(response.body);

    for (final jsonMap in jsonList) {
      journalsList.add(Journal.fromMap(jsonMap));
    }
    return journalsList;
  }

  Future<bool> edit(
      {required String id,
      required Journal journal,
      required String token}) async {
    journal.updatedAt = DateTime.now();
    String jsonJournal = jsonEncode(journal.toMap());
    http.Response response = await client.put(
      Uri.parse("${getUrl()}$id"),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonJournal,
    );
    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw InvalidTokenException();
      }
      throw HttpException(response.body);
    }
    return Future.value(true);
  }

  Future<bool> delete({required String id, required String token}) async {
    http.Response response = await http.delete(
      Uri.parse("${getUrl()}$id"),
      headers: {"Authorization": "Bearer $token"},
    );
    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwt expired") {
        throw InvalidTokenException();
      }
      throw HttpException(response.body);
    }
    return Future.value(true);
  }
}

class InvalidTokenException implements Exception {}
