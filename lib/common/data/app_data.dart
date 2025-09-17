import 'package:shared_preferences/shared_preferences.dart';

class AppData {

  static Future saveAccessToken(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('access_token', data);
  }

  static Future<String> getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('access_token') ?? '';
    return data;
  }


  static Future saveName(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('name', data);
  }

  static Future getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('name') ?? '';
    return data;
  }

  static Future saveEmail(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('email', data);
  }

  static Future getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('email') ?? '';
    return data;
  }


  static Future saveCurrency(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('currency', data);
  }

  static Future getCurrency() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('currency') ?? 'EGP';
    return data;
  }




  static Future saveIsFirst(bool data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool('is_first', data);
  }

  static Future getIsFirst() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_first') ?? true;
  }

  static Future saveDeviceId(String data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString('DeviceId', data);
  }

  static Future getDeviceId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('DeviceId') ?? '';
    return data;
  }

  static Future saveUserId(int data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setInt('user_id', data);
  }

  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }


  // static String appName = 'Webinar';
  static bool canShowFinalizeSheet = true;
}
