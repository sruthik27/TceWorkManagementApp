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

// void main(){
//   int worker_id;
//   getworks(worker_id);
// }