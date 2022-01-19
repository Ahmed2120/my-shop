import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_shop/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token = '';
  late DateTime _expiryDate;
  String _userId = '';
  late Timer _authTimer;

  bool get isAuth {
    return token.isEmpty;
  }

  String get token {
    if (_token == '' && _expiryDate.isAfter(DateTime.now())) return _token;
    return '';
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async{
    final url = 'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBnnKWZnfT4S8BQqVsnWhNcvSl-tF8EDOU';
    try{
      final res = await http.post(Uri.parse(url), body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true
      }));
      final responseData = json.decode(res.body);
      if(responseData['error'] != null){
        HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));

      _autoLogout();
      notifyListeners();
      
      final prefs = await SharedPreferences.getInstance();
      String userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
      });
      prefs.setString('userData', userData);
    }catch(e){
      throw e;
    }
  }

  Future signUp(String email, String password) async{
    return _authenticate(email, password, 'signUp');
  }
  Future logIn(String email, String password) async{
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogIn() async{
    final prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey('userData')) return false;
    final extractedData = json.decode(prefs.getString('userData')!) as Map<String, String>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']!);
    if(expiryDate.isBefore(DateTime.now())) return false;

    _token = extractedData['token']!;
    _userId = extractedData['userId']!;
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> logout() async{
    _token = '';
    _userId = '';
    _authTimer.cancel();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void _autoLogout(){
    _authTimer.cancel();

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    Timer(Duration(seconds: timeToExpiry), logout);
  }
}
