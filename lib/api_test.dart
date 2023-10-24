import 'dart:convert';

import 'package:dio/dio.dart';

Future<void> handleRegister() async {
  var data = {
    'worker_name': 'Loki',
    'email': 'loki@marvel.com',
    'phone_number': '+15555555555',
    'password': 'thor',
  };

  var dio = Dio();
  var response = await dio.request(
    'https://tceworkmanagement.azurewebsites.net/db/addworker',
    options: Options(
      method: 'POST',
    ),
    data: data,
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
  } else {
    print(response.statusMessage);
  }
}

Future<void> handleLogin() async {
  var data = {
    'useremail': 'john.doe@example.co',
    'userpassword': 'password',
  };

  var dio = Dio();
  try {
    var response = await dio.request(
      'https://tceworkmanagement.azurewebsites.net/db/workerlogin',
      options: Options(
        method: 'POST',
      ),
      data: data,
    );

    if (response.statusCode == 200) {
      print('verified');
      print(json.encode(response.data));
    } else {
      print(response.statusMessage);
    }
  } on Exception catch (e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        print('You are not authorized.');
      } else if (e.response?.statusCode == 404) {
        print('Email not exists');
      } else {
        print('An error occurred: ${e.toString()}');
      }
    } else {
      print('An unexpected error occurred: ${e.toString()}');
    }
  }
}

Future<List> getworks(int id) async {
  var dio = Dio();
  var response = await dio.request(
    'https://tceworkmanagement.azurewebsites.net/db/getworksbyid?workerid=$id',
    options: Options(
      method: 'GET',
    ),
  );

  if (response.statusCode == 200) {
    print("++++++++++++++++++ ${response.data.runtimeType}\n");
    print(response.data);
    return response.data;
  } else {
    print(response.statusMessage);
    return [];
  }
}

Future<void> gettasks(int workid) async {
  var dio = Dio();
  var response = await dio.request(
    'https://tceworkmanagement.azurewebsites.net/db/gettasks?n=$workid',
    options: Options(
      method: 'GET',
    ),
  );
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = response.data;
    print(jsonData);
  }
  else {
    print(response.statusMessage);
  }
}

Future<void> changeorder(int task_id,int new_order) async{
  var dio = Dio();
  var response = await dio.request(
    'https://tceworkmanagement.azurewebsites.net/db/updateorder?task_id=${task_id}&new_order=$new_order',
    options: Options(
      method: 'PUT',
    ),
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
  }
  else {
    print(response.statusMessage);
  }
}

Future<void> updatecompletion(int task_id) async {
  var dio = Dio();
  var response = await dio.request(
    'https://tceworkmanagement.azurewebsites.net/db/updatetaskcompletion?task_id=$task_id',
    options: Options(
      method: 'PUT',
    ),
  );

  if (response.statusCode == 200) {
    print(json.encode(response.data));
  }
  else {
    print(response.statusMessage);
  }
}

Future<void> addimageurl(String id, String url) async {
  final dio = Dio();

  final requestData = {
    'id': id,
    'url': url,
  };

  try {
    final response = await dio.put(
      'https://tceworkmanagement.azurewebsites.net/db/appendimage',
      options: Options(
        method: 'PUT',
        headers: {
          Headers.contentTypeHeader: 'application/json',
        },
      ),
      data: requestData,
    );

    if (response.statusCode == 200) {
      print(response.data);
    } else {
      print(response.statusMessage);
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> handleQuery(int work, String message) async {
  final jsonData = {
    'work': work,
    'message': message,
    'who': 'W',
  };
  
  final dio = Dio();
  final response = await dio.post(
    'https://tceworkmanagement.azurewebsites.net/db/addquery', // Replace with your actual API endpoint
    data: jsonData,
    options: Options(
      contentType: Headers.jsonContentType,
    ),
  );

  if (response.statusCode == 200) {
    print('Response: ${response.data}');
  } else {
    print('Error: ${response.statusMessage}');
  }
}


void main(){
  // int worker_id;
  // changeorder(908685839585640449,1);
  // updatecompletion(908685839585640449);
  // handleQuery(910760215319019521, "hello just a test");
}