import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/common/utils/http_handler.dart';
import 'package:http/http.dart';

import '../../../common/data/app_language.dart';
import '../../../locator.dart';


import 'package:http/http.dart' as http;


class AuthenticationService{

  static Future google(String email,String token, String name)async{
    try{
      String url = '${Constants.baseUrl}google/callback';

      Response res = await httpPost(
        url, 
        {
          'email': email,
          'name': name,
          'id': token,
        }
      );

      print(res.body);

      if(res.statusCode == 200){
        await AppData.saveAccessToken(jsonDecode(res.body)['data']['token']);
        return true;
      }else{

        return false;
      }

    }catch(e){
      return false;
    }
  }

  static Future facebook(String email, String token, String name)async{
    try{
      String url = '${Constants.baseUrl}facebook/callback';

      Response res = await httpPost(
        url, 
        {
          'id': token,
          'name': name,
          'email': email
        }
      );

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        await AppData.saveAccessToken(jsonDecode(res.body)['data']['token']);
        return true;
      }else{
        
        return false;
      }

    }catch(e){
      return false;
    }
  }

  static Future login(String username, String password)async{
        var deviceId = await AppData.getDeviceId();

    try{
      String url = '${Constants.baseUrl}login';

      Response res = await httpPost(
        url, 
        {
          'username': username,
          'password': password,
          'device_id': deviceId,
        },
        // headers: {
        //   'x-api-key' : Constants.apiKey,
        //   'Content-Type' : 'application/json',
        //   'Accept' : 'application/json',
        //
        // }
      );

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
           print(jsonResponse);
        print("jsonResponse['data']['user_id']");
      if(jsonResponse['success']){
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveUserId(jsonResponse['data']['user_id']); // حيث userId هو رقم المستخدم من السيرفر
        await AppData.saveEmail(username);
        await AppData.saveName('');
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse,readMessage: true);
        return false;
      }

    }catch(e){
      return false;
    }
  }


static Future<Map?> registerWithEmail(
  String registerMethod,
  String email,
  String password,
  String repeatPassword,
  String? accountType,
  List<Fields>? fields,
  String? specialties,
  File? profileImage,
) async {
  try {
        print("TEST WITH EMAIL");

    // ✅ بيانات الجهاز
    var deviceId = await AppData.getDeviceId();

    // ✅ رابط الطلب
    String url = '${Constants.baseUrl}register/step/1';

    // ✅ إعداد الطلب Multipart
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // ✅ إضافة الهيدرز
    request.headers.addAll({
      'x-api-key': Constants.apiKey,
      'Accept': 'application/json',
      'x-locale': locator<AppLanguage>().currentLanguage.toLowerCase(),
    });

    // ✅ البيانات الأساسية
    request.fields.addAll({
      'register_method': registerMethod,
      'email': email,
      'password': password,
      'password_confirmation': repeatPassword,
      'category_id': specialties ?? '',
      'device_id': deviceId,
      // 'country_code': '', // حسب المطلوب في الـ API
    });

    print("🔽 Request fields: ${request.fields}");

    // ✅ لو فيه بيانات إضافية (custom fields)
    if (fields != null) {
      for (var field in fields) {
        if (field.type != 'upload') {
          final value = field.type == 'toggle'
              ? (field.userSelectedData == null ? '0' : '1')
              : field.userSelectedData.toString();
          request.fields['fields[${field.id}]'] = value;
        }
      }
    }

    // ✅ لو فيه صورة مرفقة
    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        profileImage.path,
      ));
    }

    // ✅ إرسال الطلب
    http.StreamedResponse streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    print("🔽 Response status: ${response.statusCode}");
    print("🔽 Response body: ${response.body}");

    var jsonResponse = jsonDecode(response.body);

    if (jsonResponse['success'] == true ||
        jsonResponse['status'] == 'go_step_2' ||
        jsonResponse['status'] == 'go_step_3') {
      return {
        'user_id': jsonResponse['data']['user_id'],
        'step': jsonResponse['status']
      };
    } else {
      ErrorHandler().showError(ErrorEnum.error, jsonResponse);
      return null;
    }
  } catch (e) {
    print("❌ Error in registerWithEmail: $e");
    return null;
  }
}


  // static Future<Map?> registerWithEmail(
  //     String registerMethod,
  //     String email,
  //     String password,
  //     String repeatPassword,
  //     String? accountType,
  //     List<Fields>? fields,
  //     String? specialties,
  //     ) async {
  //   try {
  //     var deviceId = await AppData.getDeviceId();

  //     String url = '${Constants.baseUrl}register/step/1';

  //     Map body = {
  //       "register_method": registerMethod,
  //       "country_code": null,
  //       'email': email,
  //       'password': password,
  //       'password_confirmation': repeatPassword,
  //       "category_id": specialties,
  //       'device_id': deviceId,
  //     };

  //     if (fields != null) {
  //       Map bodyFields = {};
  //       for (var i = 0; i < fields.length; i++) {
  //         if (fields[i].type != 'upload') {
  //           bodyFields.addEntries({
  //             fields[i].id: (fields[i].type == 'toggle')
  //                 ? fields[i].userSelectedData == null
  //                 ? 0
  //                 : 1
  //                 : fields[i].userSelectedData
  //           }.entries);
  //         }
  //       }

  //       body.addEntries({'fields': bodyFields.toString()}.entries);
  //     }

  //     Response res = await httpPost(url, body);
  //     print(body);
  //     print("body registerWithEmail");
  //     print(res.body);
  //     print("res after httpPost");

  //     var jsonResponse = jsonDecode(res.body);
  //     if (jsonResponse['success'] ||
  //         jsonResponse['status'] == 'go_step_2' ||
  //         jsonResponse['status'] == 'go_step_3') {
  //       return {
  //         'user_id': jsonResponse['data']['user_id'],
  //         'step': jsonResponse['status']
  //       };
  //     } else {
  //       ErrorHandler().showError(ErrorEnum.error, jsonResponse);
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

static Future<Map?> registerWithPhone(
  String registerMethod,
  String countryCode,
  String mobile,
  String password,
  String repeatPassword,
  String? accountType,
  List<Fields>? fields,
  String? categoryId,
  File? profileImage,
) async {
  try {
    print("TEST WITH PHONE");
    final url = '${Constants.baseUrl}register/step/1';
    final deviceId = await AppData.getDeviceId();

    final request = http.MultipartRequest('POST', Uri.parse(url));

    // ✅ Headers
    request.headers.addAll({
      'x-api-key': Constants.apiKey,
      'Accept': 'application/json',
      'x-locale': locator<AppLanguage>().currentLanguage.toLowerCase(),
    });

    // ✅ Basic Fields
    request.fields.addAll({
      'register_method': registerMethod,
      'country_code': countryCode,
      'mobile': mobile,
      'password': password,
      'password_confirmation': repeatPassword,
      'device_id': deviceId,
      'category_id': categoryId ?? '',
    });

        print("🔽 Request fields: ${request.fields}");


    // ✅ Dynamic Fields
    if (fields != null) {
      for (var field in fields) {
        if (field.type != 'upload') {
          final value = field.type == 'toggle'
              ? (field.userSelectedData == null ? '0' : '1')
              : field.userSelectedData.toString();
          request.fields['fields[${field.id}]'] = value;
        }
      }
    }

    // ✅ Profile Image (optional)
    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        profileImage.path,
      ));
    }

    // ✅ Execute request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("🔽 Response status: ${response.statusCode}");
    print("🔽 Response body: ${response.body}");

    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['success'] == true ||
        jsonResponse['status'] == 'go_step_2' ||
        jsonResponse['status'] == 'go_step_3') {
      return {
        'user_id': jsonResponse['data']['user_id'],
        'step': jsonResponse['status'],
      };
    } else {
      ErrorHandler().showError(ErrorEnum.error, jsonResponse);
      return null;
    }
  } catch (e) {
    print("❌ Error in registerWithPhone: $e");
    return null;
  }
}



//   static Future<Map?> registerWithPhone(String registerMethod,String countryCode, String mobile, String password,String repeatPassword, String? accountType, List<Fields>? fields,String? categoryId,
// )async{
//     // try{
//       String url = '${Constants.baseUrl}register/step/1';
//     var deviceId = await AppData.getDeviceId();

//       Map body = {
//         "register_method": registerMethod,
//         "country_code": countryCode,
//         'mobile': mobile,
//         'password': password,
//         'password_confirmation': repeatPassword,
//                 'device_id': deviceId,
//         "category_id": categoryId,

//       };
      
//       if(fields != null){
//         Map bodyFields = {};
//         for (var i = 0; i < fields.length; i++) {
//           if(fields[i].type != 'upload'){
//             bodyFields.addEntries(
//               {
//                 fields[i].id: (fields[i].type == 'toggle') 
//                   ? fields[i].userSelectedData == null ? 0 : 1
//                   : fields[i].userSelectedData
//               }.entries
//             );
//           }
//         }

//         body.addEntries({'fields': bodyFields.toString()}.entries);        
//       }

//       Response res = await httpPost(
//         url, 
//         body
//       );

//       print(res.body);
//       print("res.body Phone");

//       var jsonResponse = jsonDecode(res.body);
//        if( jsonResponse['success'] || jsonResponse['status'] == 'go_step_2' || jsonResponse['status'] == 'go_step_3' ){ // || stored
        
//         return {
//           'user_id': jsonResponse['data']['user_id'],
//           'step': jsonResponse['status']
//         };
//       }else{
//         ErrorHandler().showError(ErrorEnum.error, jsonResponse);
//         return null;
//       }

//     // }catch(e){
//     //   return null;
//     // }
//   }
  
  static Future<bool> forgetPassword(String email)async{
    try{
      String url = '${Constants.baseUrl}forget-password';

      Response res = await httpPost(
        url, 
        {
          "email": email
        }
      );

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        
        ErrorHandler().showError(ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      return false;
    }
  }
  
  static Future<bool> verifyCode(int userId,String code)async{
    try{
      String url = '${Constants.baseUrl}register/step/2';

      Response res = await httpPost(
        url, 
        {
          "user_id": userId.toString(),
          "code": code,
        }
      );

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      return false;
    }
  }
  
  static Future<bool> registerStep3(int userId, String name, String referralCode)async{
    try{
      String url = '${Constants.baseUrl}register/step/3';

      Response res = await httpPost(
        url, 
        {
          "user_id": userId.toString(),
          "full_name": name,
          "referral_code": referralCode
        }
      );


      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName(name);
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      return false;
    }
  }

  
}