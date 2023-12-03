import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:work_management_app/homepage.dart';
import 'package:work_management_app/registration.dart';
import 'package:dio/dio.dart';
import 'firebase_options.dart';
import 'package:email_otp/email_otp.dart';

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
  ));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TCE Work Management',
      home: MyHomePage(title: 'TCE Work Management'),
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
  Future<void> sendmail(String email) async {
    setState(() {
      isLoading = true;
    });
    Dio dio = Dio();

    String url = 'https://tceworkmanagement.azurewebsites.net/db/resetpass?mailid=$email';

    try {
      Response response = await dio.post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: jsonEncode({}),
      );
      if (response.statusCode == 200) {
        var data = response.data;
        print(data);
      } else {
        print('Error: ${response.statusCode}');
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
    await myAuth.setSMTP(
        host: "smtp.gmail.com",
        auth: true,
        username: "insomniadevs007@gmail.com",
        password: "lzhyecgavxzkcgvg",
        secure: "SSL",
        port: 587
    );
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
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PASSWORD CHANGED'),
            ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New passwords do not match'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid or expired OTP'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () async {
                if (emailController.text!="") {
                  await generateOtpAndSendEmail();
                  showDialog(
                    context: context,
                    builder: (context) {
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
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                // Navigate to the registration page
                Navigator.of(context).pushReplacement(
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
