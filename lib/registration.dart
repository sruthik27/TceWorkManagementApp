import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:work_management_app/main.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:work_management_app/widgets/appColors.dart';


class RegistrationForm extends StatefulWidget {
  const RegistrationForm({Key? key}) : super(key: key);
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController verifyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool passwordVisible1 = false;
  bool passwordVisible2 = false;


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
      'https://tcedmdrportal.onrender.com/db/addworker',
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(
      //       content: Text('REGISTERED'),
      //     ));
      Fluttertoast.showToast(
          msg: "REGISTERED",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else {
      print(response.statusMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSandal,
      appBar: AppBar(
        backgroundColor: AppColors.darkBrown,
        foregroundColor: Colors.white,
        title: const Text('Registration'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('WELCOME',style: TextStyle(
                  color: AppColors.darkBrown,
                  fontSize: 25,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),),
                Text('Enter your details and submit to register as an official agency in TCE DMDR',textAlign: TextAlign.center,),
                SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Agency/Your Name',
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
                      labelText: 'Email (existing active one)',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    obscureText: !passwordVisible1,
                    controller: passwordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible1 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible1 = !passwordVisible1;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      if (value != confirmPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    obscureText: !passwordVisible1,
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible1 ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible1 = !passwordVisible1;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20,),
                Column(
                  children: <Widget>[
                    Text('Verification Code (get from TCE MDR head to sign up)'),
                    OtpTextField(
                      enabledBorderColor: Colors.grey,
                      numberOfFields: 4,
                      borderColor: AppColors.darkBrown,
                      borderWidth: 3.0,
                      borderRadius: BorderRadius.circular(10),
                      fieldWidth: 40,
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
                    child: const Text('Register'),style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.lightSandal,
                    backgroundColor: AppColors.darkBrown, // Set the text color
                    // You can customize other properties like padding, elevation, shape, etc.
                  ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        handleRegister();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MyHomePage(title: 'Login page'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
