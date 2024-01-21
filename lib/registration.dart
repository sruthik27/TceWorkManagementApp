import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tce_dmdr/widgets/appColors.dart';
import 'package:tce_dmdr/main.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:tce_dmdr/widgets/appColors.dart';


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
      else{
        Fluttertoast.showToast(
            msg: "REGISTERED",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
    else {
      print(response.statusMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.darkBrown, // Set the desired color
    ));
    return Scaffold(
      backgroundColor: AppColors.lightSandal,
      appBar: AppBar(
        backgroundColor: AppColors.darkBrown,
        foregroundColor: Colors.white,
        title: const Text('REGISTRATION',style: TextStyle(fontFamily: 'LexendDeca'),),
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
                  fontSize: 27,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                ),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Register to join as a TCE DMDR agency',textAlign: TextAlign.center,style: TextStyle(fontFamily: 'NotoSans',fontWeight: FontWeight.bold),),
                ),
                SizedBox(height: 10,),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Agency/Your Name',
                      labelStyle: TextStyle(fontFamily: 'Inter')
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
                      labelText: 'Your Phone',
                        labelStyle: TextStyle(fontFamily: 'Inter')
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Your Email',
                        labelStyle: TextStyle(fontFamily: 'Inter')
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
                      labelText: 'Set Password',
                      labelStyle: TextStyle(fontFamily: 'Inter'),
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
                      labelStyle: TextStyle(fontFamily: 'Inter'),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text('Verification Code (get from TCE-DMDR head)',style: TextStyle(fontFamily: 'NotoSans',fontWeight: FontWeight.bold,fontSize: 16),textAlign:TextAlign.center),
                    ),
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
                SizedBox(height: 30),
                Container(
                  height: 50,
                  width: 300,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child: const Text('Register',style: TextStyle(fontFamily: 'Inter',fontWeight: FontWeight.bold,fontSize: 24),),style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.darkSandal,
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
