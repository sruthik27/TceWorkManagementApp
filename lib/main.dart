import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:work_management_app/homepage.dart';
import 'package:work_management_app/registration.dart';
import 'package:dio/dio.dart';
import 'firebase_options.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';


import 'package:work_management_app/widgets/appColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

int worker_id = 0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  int workerId = prefs.getInt('worker_id') ?? 0;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'TCE Work Management',
    home: isLoggedIn ? HomePage(workerId) : const MyHomePage(title: 'TCE Work Management'),
      theme:ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.lightBlue,
          secondary: Colors.lightBlue, // Secondary is the equivalent of the old accentColor
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.lightBlue),
          bodyMedium: TextStyle(color: Colors.lightBlue),
          // Add other text styles if needed
        ),
        iconTheme: IconThemeData(
          color: Colors.lightBlue,
        ),
      ),
  ));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TCE Work Management',
      home: MyHomePage(title: 'TCE Work Management'),
      theme: ThemeData(primaryColor: AppColors.darkBrown),
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
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  bool passwordVisible = false;
  bool isLoading = false;
  String? generatedOtp;
  DateTime? otpGeneratedTime;
  EmailOTP myAuth = EmailOTP();

  Future<bool> handleLogin() async {
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
        worker_id = int.parse(response.data.toString());
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('worker_id', worker_id);
        await prefs.setBool('isLoggedIn', true);
        return true;
      }
      return false;
    } on Exception catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wrong password'),
            ),
          );
        } else if (e.response?.statusCode == 404) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email does not exist'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Problem in backend'),
            ),
          );
          print('An error occurred: ${e.toString()}');
        }
        return false;
      } else {
        print('An unexpected error occurred: ${e.toString()}');
        return false;
      }
    }
  }

  Future<void> changepass() async {
    setState(() {
      isLoading = true;
    });
    String url = 'https://tceworkmanagement.azurewebsites.net/db/resetpass';
    try {
      var headers = {
        'Content-Type': 'application/json'
      };
      var data = json.encode({
        "email": emailController.text,
        "newpass": newPasswordController.text,
        "oldpass": ""
      });
      var dio = Dio();
      var response = await dio.request(url,
        options: Options(
          method: 'PUT',
          headers: headers,
        ),
        data: data,
      );
      if (response.statusCode == 200) {
        print(json.encode(response.data));
      }
      else {
        print(response.statusMessage);
      }
    } catch (error) {
      print('Error: $error');
    }
    finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const SpinKitFadingCircle(
                color: AppColors.darkSandal,
                size: 100.0,
        );
      },
    );
  }

  Future<void> generateOtpAndSendEmail() async {
    otpGeneratedTime = DateTime.now();
    // await myAuth.setSMTP(
    //     host: "smtp.gmail.com",
    //     auth: true,
    //     username: "insomniadevs007@gmail.com",
    //     password: "lzhyecgavxzkcgvg",
    //     secure: "SSL",
    //     port: 587
    // );
    await myAuth.setConfig(
      appEmail: "insomniadevs007@gmail.com",
      appName: "TCE MDR",
      userEmail: emailController.text,
      otpLength: 6,
      otpType: OTPType.digitsOnly,
    );
    await myAuth.sendOTP();
  }

  Future<void> verifyOtpAndChangePassword() async {
    bool verified = await myAuth.verifyOTP(
        otp: otpController.text
    );
    if (verified &&
        DateTime.now().difference(otpGeneratedTime!).inMinutes < 5) {
      if (newPasswordController.text == confirmNewPasswordController.text) {
        print('----------verified------------');
        await changepass();
        Navigator.of(context).pop();
        Fluttertoast.showToast(
            msg: "PASSWORD CHANGED",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      } else {
          Fluttertoast.showToast(
              msg: "Passwords do not match",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );

          print('passwords don\'t match');
      }
    } else {
        Fluttertoast.showToast(
            msg: "OTP wrong",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSandal,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: AppColors.darkBrown,
        foregroundColor: Colors.white,
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
                obscureText: !passwordVisible,
                controller: passwordController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            )
            ,TextButton(
              child: const Text(
                'Forgot Password?',
                style: TextStyle(color: AppColors.darkBrown),
              ),
              onPressed: () async {
                if (emailController.text!="") {
                  await generateOtpAndSendEmail();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                            title: Text('Enter OTP and New Password'),
                            content: Column(
                              children: <Widget>[
                                TextField(
                                  controller: otpController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter OTP',
                                  ),
                                ),
                                TimerCountdown(
                                  format: CountDownTimerFormat.minutesSeconds,
                                  endTime: DateTime.now().add(Duration(minutes: 5)),
                                  onEnd: () {
                                    print("Timer finished");
                                    Navigator.of(context).pop();
                                  },
                                  timeTextStyle: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                                ),
                                TextField(
                                  controller: newPasswordController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter new password',
                                  ),
                                ),
                                TextField(
                                  controller: confirmNewPasswordController,
                                  decoration: InputDecoration(
                                    hintText: 'Confirm new password',
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Submit'),
                                onPressed: () {
                                  verifyOtpAndChangePassword();
                                },
                              ),
                            ],
                          );
                        }
                      );
                    },
                  );
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fill the email field and click forgot'),
                    ),
                  );
                }
              },
            ),
            if (isLoading)
              Center(
                child: SpinKitFadingCircle(
                  color: AppColors.darkSandal,
                  size: 100.0,
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBrown,
            foregroundColor: AppColors.lightSandal
            // You can customize other properties like padding, elevation, shape, etc.
            ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  showLoadingDialog(context);
                  bool success = await handleLogin();
                  Navigator.pop(context);  // Dismiss the dialog
                  if (success) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomePage(worker_id)),
                    );
                  }
                }
              },
              child: const Text('Login'),
            ),
            TextButton(
              child: const Text(
                'Register Now',
                style: TextStyle(color: AppColors.darkBrown),
              ),
              onPressed: () {
                // Navigate to the registration page
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegistrationForm(),
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
