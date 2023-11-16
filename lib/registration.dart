import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:work_management_app/main.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';


class RegistrationForm extends StatefulWidget {
  const RegistrationForm({Key? key}) : super(key: key);
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController verifyController = TextEditingController();

  Future<void> handleRegister() async {
    var data = {
      'worker_name': nameController.text,
      'email': emailController.text,
      'phone_number': phoneController.text,
      'password': passwordController.text,
      'verificationcode':verifyController.text,
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
      if (json.encode(response.data).contains('check fail')) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Verification Error'),
              content: Text('The verification code is wrong.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
    else {
      print(response.statusMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Name',
                ),
              ),
            ),Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Phone',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            SizedBox(height: 20,),
            Column(
              children: <Widget>[
                Text('Verification Code'),
                OtpTextField(
                  numberOfFields: 4,
                  borderColor: Colors.blue,
                  borderWidth: 2.0,
                  borderRadius: BorderRadius.circular(10),
                  fieldWidth: 40,
                  showFieldAsBox: true,
                  onSubmit: (String verificationCode) {
                    setState(() {
                      verifyController.text = verificationCode;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                child: const Text('Register'),
                onPressed: () {
                  handleRegister();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MyHomePage(title: 'Login page'),
                    ),);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
