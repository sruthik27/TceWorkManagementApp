import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:work_management_app/homepage.dart';
import 'package:work_management_app/registration.dart';
import 'package:dio/dio.dart';
import 'package:work_management_app/widgets/appColors.dart';

int worker_id = 0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TCE Work Management',
      home: const MyHomePage(title: 'TCE Work Management'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> handleLogin() async {
    var data = {
      'useremail': emailController.text,
      'userpassword': passwordController.text,
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
        print(json.encode("-------${response.data}"));
        worker_id = int.parse(json.encode(response.data));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: AppColors.darkBrown,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  handleLogin();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(worker_id)),
                  );
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              child: Text(
                'Register Now',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                // Navigate to the registration page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegistrationForm(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
