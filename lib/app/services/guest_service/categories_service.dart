import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:egyptm/app/models/category_model.dart';
import 'package:egyptm/app/models/filter_model.dart';
import '../../../common/enums/error_enum.dart';
import '../../../common/utils/constants.dart';
import '../../../common/utils/error_handler.dart';
import '../../../common/utils/http_handler.dart';

class CategoriesService{


  static Future<List<CategoryModel>> trendCategories()async{
    List<CategoryModel> data = [];
    try{
      String url = '${Constants.baseUrl}trend-categories';

      Response res = await httpGet(
        url, 
      );

      log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        jsonResponse['data']['categories'].forEach((json){
          data.add(CategoryModel.fromJson(json));
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

  static Future<List<CategoryModel>> categories({bool isRegister= false})async{
    List<CategoryModel> data = [];
    try{
      String url = '${Constants.baseUrl}categories';

      print(url);
      print("url");
      Response res = await httpGet(
        url,
        isSendToken: !isRegister, // if isRegister is true, we don't send token
      );

      

      var jsonResponse = jsonDecode(res.body);
      log(jsonResponse.toString());
      print("categories jsonResponse");
      if(jsonResponse['success']){
        jsonResponse['data']['categories'].forEach((json){
          data.add(CategoryModel.fromJson(json));
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

  Future<List<CategoryModel>> fetchCategories() async {
    // final response = await http.get(Uri.parse(apiUrl));

    String url = '${Constants.baseUrl}categories';

    print(url);
    print("url");
    Response res = await httpGet(
      url,
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      print(data);
      print("fetchCategories data");
      return (data['data']['categories'] as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load categories");
    }
  }


  static Future<List<FilterModel>> getFilters(int id)async{
    List<FilterModel> data = [];
    try{
      String url = '${Constants.baseUrl}categories/$id/webinars';

      Response res = await httpGet(
        url, 
      );

      

      var jsonResponse = jsonDecode(res.body);
      if(jsonResponse['success']){
        jsonResponse['data']['filters'].forEach((json){
          data.add(FilterModel.fromJson(json));
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
   
}
