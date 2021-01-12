import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:myanimelist/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:slack_notifier/slack_notifier.dart';

const clientId = '';
const tokenUri = 'https://myanimelist.net/v1/oauth2/token';
const authorizeUri = 'https://myanimelist.net/v1/oauth2/authorize';
const apiBaseUrl = 'https://api.myanimelist.net/v2';

class MalClient {
  Future<String> login() async {
    final verifier = _generateCodeVerifier();
    final loginUrl = _generateLoginUrl(verifier);

    try {
      final uri = await FlutterWebAuth.authenticate(url: loginUrl, callbackUrlScheme: 'javoeria.animedb');
      final queryParams = Uri.parse(uri).queryParameters;
      print(queryParams);
      if (queryParams['error'] == 'access_denied') return null;

      Fluttertoast.showToast(msg: 'Login Successful');
      final tokenJson = await _generateTokens(verifier, queryParams['code']);
      final username = await _getUserName(tokenJson['access_token']);
      if (kReleaseMode) {
        tokenJson['datetime'] = DateTime.now();
        FirebaseFirestore.instance.collection('test').doc(username).set(tokenJson);
        SlackNotifier(kSlackToken).send('User Login $username', channel: 'jikan');
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      return username;
    } on PlatformException {
      return null;
    }
  }

  Future<String> refresh() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    final doc = await FirebaseFirestore.instance.collection('test').doc(username).get();
    final tokenJson = await _refreshTokens(doc.data()['refresh_token']);
    if (kReleaseMode) {
      tokenJson['datetime'] = DateTime.now();
      FirebaseFirestore.instance.collection('test').doc(username).set(tokenJson);
      SlackNotifier(kSlackToken).send('User Refresh $username', channel: 'jikan');
    }
    return tokenJson['access_token'];
  }

  Future<Map<String, dynamic>> getStatus(int id, {bool anime = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    if (username == null) return null;

    final doc = await FirebaseFirestore.instance.collection('test').doc(username).get();
    if (doc.data() == null) return null;

    String accessToken = doc.data()['access_token'];
    DateTime expiredAt = doc.data()['datetime'].toDate().add(Duration(seconds: doc.data()['expires_in']));
    if (DateTime.now().isAfter(expiredAt)) accessToken = await refresh();

    final statusJson = anime ? await _getAnimeStatus(id, accessToken) : await _getMangaStatus(id, accessToken);
    return statusJson;
  }

  Future<Map<String, dynamic>> setStatus(int id,
      {bool anime = true, String status, String score, String episodes, String volumes, String chapters}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username');
    final doc = await FirebaseFirestore.instance.collection('test').doc(username).get();

    String accessToken = doc.data()['access_token'];
    final statusJson = anime
        ? await _setAnimeStatus(id, accessToken, status: status, score: score, episodes: episodes)
        : await _setMangaStatus(id, accessToken, status: status, score: score, volumes: volumes, chapters: chapters);
    if (kReleaseMode) SlackNotifier(kSlackToken).send('Edit Status $username $id $statusJson}', channel: 'jikan');
    return statusJson;
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(200, (i) => random.nextInt(256));
    return base64UrlEncode(values).substring(0, 128);
  }

  String _generateLoginUrl(String verifier) {
    return '$authorizeUri?response_type=code&client_id=$clientId&code_challenge=$verifier';
  }

  Future<dynamic> _generateTokens(String verifier, String code) async {
    final params = {
      'client_id': clientId,
      'code': code,
      'code_verifier': verifier,
      'grant_type': 'authorization_code',
    };
    final response = await http.post(tokenUri, body: params);
    return jsonDecode(response.body);
  }

  Future<dynamic> _refreshTokens(String refreshToken) async {
    final params = {
      'client_id': clientId,
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
    };
    final response = await http.post(tokenUri, body: params);
    return jsonDecode(response.body);
  }

  Future<String> _getUserName(String accessToken) async {
    final response = await http.get('$apiBaseUrl/users/@me', headers: {'Authorization': 'Bearer $accessToken'});
    final userJson = jsonDecode(response.body);
    return userJson['name'];
  }

  Future<Map<String, dynamic>> _getAnimeStatus(int id, String accessToken) async {
    final url = '$apiBaseUrl/anime/$id?fields=my_list_status,num_episodes';
    final response = await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});
    final animeJson = jsonDecode(response.body);
    if (animeJson['my_list_status'] == null) {
      animeJson['my_list_status'] = {'score': 0, 'num_episodes_watched': '', 'text': 'ADD TO MY LIST'};
    } else {
      animeJson['my_list_status']['text'] = animeJson['my_list_status']['status'].replaceAll('_', ' ').toUpperCase();
    }
    animeJson['my_list_status']['id'] = id;
    animeJson['my_list_status']['total_episodes'] = animeJson['num_episodes'] ?? 0;
    return animeJson['my_list_status'];
  }

  Future<Map<String, dynamic>> _getMangaStatus(int id, String accessToken) async {
    final url = '$apiBaseUrl/manga/$id?fields=my_list_status,num_volumes,num_chapters';
    final response = await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});
    final mangaJson = jsonDecode(response.body);
    if (mangaJson['my_list_status'] == null) {
      mangaJson['my_list_status'] = {
        'score': 0,
        'num_volumes_read': '',
        'num_chapters_read': '',
        'text': 'ADD TO MY LIST'
      };
    } else {
      mangaJson['my_list_status']['text'] = mangaJson['my_list_status']['status'].replaceAll('_', ' ').toUpperCase();
    }
    mangaJson['my_list_status']['id'] = id;
    mangaJson['my_list_status']['total_volumes'] = mangaJson['num_volumes'] ?? 0;
    mangaJson['my_list_status']['total_chapters'] = mangaJson['num_chapters'] ?? 0;
    return mangaJson['my_list_status'];
  }

  Future<Map<String, dynamic>> _setAnimeStatus(int id, String accessToken,
      {String status, String score, String episodes}) async {
    final params = {
      'status': status,
      'score': score,
      'num_watched_episodes': episodes == '?' ? '0' : episodes,
    };
    final url = '$apiBaseUrl/anime/$id/my_list_status';
    final response = await http.put(url, body: params, headers: {'Authorization': 'Bearer $accessToken'});
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> _setMangaStatus(int id, String accessToken,
      {String status, String score, String volumes, String chapters}) async {
    final params = {
      'status': status,
      'score': score,
      'num_volumes_read': volumes == '?' ? '0' : volumes,
      'num_chapters_read': chapters == '?' ? '0' : chapters,
    };
    final url = '$apiBaseUrl/manga/$id/my_list_status';
    final response = await http.put(url, body: params, headers: {'Authorization': 'Bearer $accessToken'});
    return jsonDecode(response.body);
  }
}
