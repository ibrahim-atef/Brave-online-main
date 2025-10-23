import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:egyptm/app/models/content_model.dart';
import 'package:egyptm/app/models/course_model.dart';
import 'package:egyptm/app/models/notice_model.dart';
import 'package:egyptm/app/models/single_course_model.dart';
import 'package:egyptm/app/models/user_model.dart';
import 'package:egyptm/common/data/api_public_data.dart';
import 'package:egyptm/common/utils/constants.dart';
import 'package:http/http.dart';
import 'package:egyptm/common/utils/http_handler.dart';

import '../../../common/enums/error_enum.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/components.dart';
import '../../models/single_content_model.dart';

class CourseService{


static Future<dynamic> fetchConversationId({int? course_id}) async {
  try {
    String url = '${Constants.baseUrl}panel/conversations/$course_id';
    print("📤 [API REQUEST] ➜ $url");

    Response res = await httpGet(
      url,
      isSendToken: true,
    );

    print("📥 [API RESPONSE] ➜ Status Code: ${res.statusCode}");

    if (res.body.isEmpty) {
      print("❌ [ERROR] ➜ Empty Response Body");
      return "Error";
    }

    try {
      var jsonRes = jsonDecode(res.body);
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      print("🗂️ [JSON DATA] ➜\n${encoder.convert(jsonRes)}");

      if (jsonRes != null) {
        return jsonRes;
      } else {
        print("❌ [ERROR] ➜ Null JSON Response");
        return "Error";
      }
    } catch (jsonErr) {
      print("❌ [ERROR] ➜ Failed to parse JSON: $jsonErr");
      return "Error";
    }

  } catch (e) {
    print("❌ [EXCEPTION] ➜ $e");
    return "Error";
  }
}


static Future<bool> sendMessage({
  required int conversationId,
  required String message,
}) async {
  try {
          String url = '${Constants.baseUrl}panel/conversations/$conversationId/messages';

    // final url = '${Constants.baseUrl}panel/conversations/$conversationId/messages';
    print('[DEBUG] 📤 Sending message to $url');
    
    final response = await httpPostWithToken(
      url,
      {
        'message': message,
      },
    );

    print('[DEBUG] 📬 Response Status: ${response.statusCode}');
    print('[DEBUG] 📬 Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('[DEBUG] ✅ Message sent successfully via CourseService');
      return true;
    } else {
      print('[DEBUG] ❌ Failed to send message via CourseService');
      return false;
    }
  } catch (e) {
    print('[DEBUG] 🛑 Exception in CourseService.sendMessage: $e');
    return false;
  }
}

  static Future<bool> sendMessageWithFile({
  required int conversationId,
  required String message,
  required File file,
  String fileMimeType = 'application/octet-stream',
}) async {
  try {
    Uri url = Uri.parse('${Constants.baseUrl}panel/conversations/$conversationId/messages');

    print('[DEBUG] 📤 Sending message with attachment to $url');

    final response = await httpPostFileWithToken(
      url,
      {
        'message': message,
      },
      file,
      fileFieldName: 'attachment', // ✅ اسم الحقل المطلوب من الـ backend
      fileMimeType: fileMimeType,
    );

    final responseBody = await response.stream.bytesToString();

    print('[DEBUG] 📬 Response Status: ${response.statusCode}');
    print('[DEBUG] 📬 Response Body: $responseBody');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('[DEBUG] ✅ Message with attachment sent successfully');
      return true;
    } else {
      print('[DEBUG] ❌ Failed to send message with attachment');
      return false;
    }
  } catch (e) {
    print('[DEBUG] 🛑 Exception in sendMessageWithFile: $e');
    return false;
  }
}





 static Future<bool> enrollment(String url, String code) async {

    try{
      print(url);
      print("url getSingleContent");
      Response res = await httpPostWithToken(
        url,
        {
          "code":code
        }
      );


      var jsonResponse = jsonDecode(res.body);

print(jsonResponse['status']);
print("jsonResponse['status']");
      if(jsonResponse['status'] == 'success'){
        print("jsonResponse['success']");

        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }

    }catch(e){
      return false;
    }
  }


  static Future<List<CourseModel>> getAll({ required int offset,bool upcoming=false, bool free=false,
    bool discount=false, bool downloadable=false, String? sort, String? type,
    String? cat, bool reward=false, bool bundle=false, List<int>? filterOption, })async{
    List<CourseModel> data = [];
    // try{
      String url = '${Constants.baseUrl}${bundle ? 'bundles' : 'courses'}?offset=$offset&limit=10';

      if(upcoming) url += '&upcoming=1';
      if(free) url += '&free=1';
      if(discount) url += '&discount=1';
      if(downloadable) url += '&downloadable=1';
      if(reward) url += '&reward=1';

      if(sort != null) url += '&sort=$sort';
      if(cat != null) url += '&cat=$cat';

      if(filterOption != null && filterOption.isNotEmpty){
        for (int i=0; i < filterOption.length; i++) {
          url += '&filter_option=${filterOption[i]}';
        }
      }

      print(url);
      print("url Courses");

      Response res = await httpGet(url,isSendToken: true);
        
      var jsonRes = jsonDecode(res.body);
    print(jsonRes);
    print("jsonRes Courses");


    if (jsonRes['success'] ?? false) {

        if(bundle){
          jsonRes['data']['bundles'].forEach((json){
            data.add(CourseModel.fromJson(json));
          });

        }else{
          jsonRes['data'].forEach((json){
            data.add(CourseModel.fromJson(json));
          });
        }

        log('course count : ${data.length}');
        return data;
      }else{
        return data;
      }

    // }catch(e){
    //   return data;
    // }
  }


  static Future<SingleCourseModel?> getOverviewCourseData(int id,bool isBundle,{bool isPrivate=false})async{
    try{

      String url = '${Constants.baseUrl}${isPrivate ? 'panel/webinars' : isBundle ? 'panel/bundles' : 'panel/webinars'}/$id';
      print(url);
      print("url getOverviewCourseData");

      Response res = await httpGet(
        url,
        isSendToken: true
      );
        
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success'] ?? false) {
        return SingleCourseModel.fromJson( 
          isBundle 
            ? jsonRes['data']['bundle'] 
            : jsonRes['data']
        );
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonRes, readMessage: true);
        return null;
      }


    }catch(e){
      return null;
    }
  }

  static Future<SingleCourseModel?> getSingleCourseData(int id,bool isBundle,{bool isPrivate=false})async{
    // try{

      String url = '${Constants.baseUrl}${isPrivate ? 'panel/webinars' : isBundle ? 'bundles' : 'courses'}/$id';
      print(url);
      print("url getSingleCourseData");

      Response res = await httpGet(
        url,
        isSendToken: true
      );
        
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success'] ?? false) {
        return SingleCourseModel.fromJson( 
          isBundle 
            ? jsonRes['data']['bundle'] 
            : jsonRes['data']
        );
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonRes, readMessage: true);
        return null;
      }


    // }catch(e){
    //   return null;
    // }
  }

  static Future<List<CourseModel>> featuredCourse({String? cat,})async{
    List<CourseModel> data = [];
    try{

      String url = '${Constants.baseUrl}featured-courses';

      if(cat != null) url += '?cat=$cat';

      print(url);
      print("url featuredCourse");
      Response res = await httpGet(url, isMaintenance: true);
        
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success']) {
        jsonRes['data'].forEach((json){
          data.add(CourseModel.fromJson(json));
        });

        log('featured course count : ${data.length}');
        return data;
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }
  

 

  static Future<List<CourseModel>> getBundleWebinars(int bundleId)async{
    List<CourseModel> data = [];
    try{

      String url = '${Constants.baseUrl}bundles/$bundleId/webinars';

      print(url);
      print("url getBundleWebinars");
      Response res = await httpGet(url, isMaintenance: true);
        
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success']) {
        jsonRes['data']['webinars'].forEach((json){
          data.add(CourseModel.fromJson(json));
        });

        return data;
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }
  
  static Future<List<CourseModel>> bundleCourses(int bundleId)async{
    List<CourseModel> data = [];
    try{

      String url = '${Constants.baseUrl}bundles/$bundleId/webinars';


      print(url);
      print("url bundleCourses");
      Response res = await httpGet(url);
        
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success']) {
        jsonRes['data']['webinars'].forEach((json){
          data.add(CourseModel.fromJson(json));
        });

        log('featured course count : ${data.length}');
        return data;
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }

  static Future<List<String>> getReasons()async{
    List<String> data = [];
    try{

      String url = '${Constants.baseUrl}courses/reports/reasons';



      print(url);
      print("url getReasons");
      Response res = await httpGet(url);
        
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success']) {
        jsonRes['data'].forEach((json){
          data.add(json);
        });

        PublicData.reasonsData = data;

        return data;
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }

  static Future<List<NoticeModel>> getNotices(int id)async{
    List<NoticeModel> data = [];
    try{

      String url = '${Constants.baseUrl}panel/webinars/$id/noticeboards';



      print(url);
      print("url getNotices");
      Response res = await httpGetWithToken(url);
        
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success']) {
        jsonRes['data'].forEach((json){
          data.add(NoticeModel.fromJson(json));
        });


        return data;
      }else{
        return data;
      }


    }catch(e){
      return data;
    }
  }

  static Future<bool> reportCourse(String reason,int courseId,String message)async{
   
    try{

      String url = '${Constants.baseUrl}courses/$courseId/report';


      print(url);
      print("url reportCourse");
      Response res = await httpPostWithToken(
        url,
        {
          "reason" : reason,
          "message" : message
        }
      );
        
      var jsonResponse = jsonDecode(res.body);

      if(jsonResponse['success']){
        showSnackBar(ErrorEnum.success, jsonResponse['message']?.toString());
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }


    }catch(e){
      return false;
    }
  }

  static Future<bool> toggle(int courseId,String itemName,String itemId,bool status)async{
   
    try{

      String url = '${Constants.baseUrl}courses/$courseId/toggle';


      print(url);
      print("url courses toggle");
      Response res = await httpPostWithToken(
        url,
        {
          "item" : itemName,
          "item_id" : itemId,
          "status" : status
        }
      );
        
      var jsonResponse = jsonDecode(res.body);
      print(jsonResponse);

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

  static Future<bool> addFavorite(int courseId, bool isBundle)async{
   
    try{

      String url = '${Constants.baseUrl}panel/favorites/toggle2';

      print(url);
      print("url addFavorite");
      Response res = await httpPostWithToken(
        url,
        {
          "item" : isBundle ? 'bundle' : 'webinar',
          "id" : courseId
        }
      );
        
      var jsonResponse = jsonDecode(res.body);

      if(jsonResponse['success']){
        ErrorHandler().showError(ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse, readMessage: true);
        return false;
      }


    }catch(e){
      return false;
    }
  }

  static Future<(List<CourseModel> courseData, List<UserModel> usersData, List<UserModel> organizationsData)> search(String text)async{
    List<CourseModel> courseData = [];
    List<UserModel> usersData = [];
    List<UserModel> organizationsData = [];

    try{

      String url = '${Constants.baseUrl}search?search=$text';


      print(url);
      print("url search");
      Response res = await httpGet(url);
        
      var jsonRes = jsonDecode(res.body);

      if (jsonRes['success']) {
        
        jsonRes['data']['webinars']['webinars'].forEach((json){
          courseData.add(CourseModel.fromJson(json));
        });
        
        jsonRes['data']['users']['users'].forEach((json){
          usersData.add(UserModel.fromJson(json));
        });
        
        jsonRes['data']['organizations']['organizations'].forEach((json){
          organizationsData.add(UserModel.fromJson(json));
        });

        return (courseData,usersData,organizationsData);
      }else{
        return (courseData,usersData,organizationsData);
      }


    }catch(e){
      return (courseData,usersData,organizationsData);
    }
  }



  static Future<List<ContentModel>> getContent(int courseId) async {
    List<ContentModel> data = [];

    try{
      String url = '${Constants.baseUrl}courses/$courseId/content';

      print(url);
      print("url getContent");
      Response res = await httpGetWithToken(
        url, 
        isRedirectingStatusCode: false
      );


      var jsonResponse = jsonDecode(res.body);


      if(jsonResponse['success']){

        jsonResponse['data'].forEach((json){
          data.add(ContentModel.fromJson(json));
        });

        return data;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return data;
      }

    }catch(e){
      return data;
    }
  }

  static Future<String?> getContentJSON(int courseId) async {

    try{
      String url = '${Constants.baseUrl}courses/$courseId/content';

      print(url);
      print("url");
      Response res = await httpGetWithToken(
        url, 
        isRedirectingStatusCode: false
      );

      var jsonResponse = jsonDecode(res.body);

      if(jsonResponse['success']){
        return jsonEncode(jsonResponse['data'] ?? {});
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }

    }catch(e){
      return null;
    }
  }



  static Future<SingleContentModel?> getSingleContent(String url) async {

    try{
      print(url);
      print("url getSingleContent");
      Response res = await httpGetWithToken(
        url, 
        isRedirectingStatusCode: false
      );


      var jsonResponse = jsonDecode(res.body);


      if(jsonResponse['success'] ?? false){

        return SingleContentModel.fromJson(jsonResponse['data']);
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }

    }catch(e){
      return null;
    }
  }

  static Future<String?> getSingleContentJSON(String url) async {

    try{
      print(url);
      print("url getSingleContentJSON");
      Response res = await httpGetWithToken(
        url, 
        isRedirectingStatusCode: false
      );


      var jsonResponse = jsonDecode(res.body);

      if(jsonResponse['success'] ?? false){

        return res.body;
      }else{
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }

    }catch(e){
      return null;
    }
  }

}
