import 'dart:convert';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tce_dmdr/homepage.dart';
import 'package:tce_dmdr/privacy_policy_page.dart';
import 'package:tce_dmdr/registration.dart';
import 'package:dio/dio.dart';
import 'package:tce_dmdr/widgets/welcome.dart';
import 'firebase_options.dart';
import 'package:email_otp/email_otp.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';

import 'package:tce_dmdr/widgets/appColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

int worker_id = 0;
bool first_time = false;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool isFirst = prefs.getBool('isFirst')??false;
  int workerId = prefs.getInt('worker_id') ?? 0;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'TCE DMDR',
    home: !isFirst ? PrivacyPolicyPage():
    isLoggedIn
        ? HomePage(workerId)
        : MyHomePage(title: 'TCE DMDR'),
    theme: ThemeData(
      colorScheme: ColorScheme.light(
        primary: AppColors.mediumBrown,
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkBrown,
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
      title: 'TCE DMDR',
      home: MyHomePage(title: 'TCE DMDR'),
      theme: ThemeData(primaryColor: AppColors.darkBrown),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

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
  FocusNode myFocusNode = new FocusNode();
  FocusNode myFocusNode2 = new FocusNode();

  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      setState(() {});
    });
    myFocusNode2.addListener(() {
      setState(() {});
    });
  }

  bool isValidEmail(String email) {
    // Define a regular expression pattern for a valid email address
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$',
    );
    // Check if the provided email matches the pattern
    return emailRegex.hasMatch(email);
  }


  Future<bool> handleLogin() async {
    var data = {
      'useremail': emailController.text,
      'userpassword': passwordController.text,
    };

    var dio = Dio();
    try {
      var response = await dio.request(
        'https://tcedmdrportal.onrender.com/db/workerlogin',
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
              content: Text('Cannot connect'),
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
    String url = 'https://tcedmdrportal.onrender.com/db/resetpass';
    try {
      var headers = {'Content-Type': 'application/json'};
      var data = json.encode({
        "email": emailController.text,
        "newpass": newPasswordController.text,
        "oldpass": ""
      });
      var dio = Dio();
      var response = await dio.request(
        url,
        options: Options(
          method: 'PUT',
          headers: headers,
        ),
        data: data,
      );
      if (response.statusCode == 200) {
        print(json.encode(response.data));
      } else {
        print(response.statusMessage);
      }
    } catch (error) {
      print('Error: $error');
    } finally {
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
    bool verified = await myAuth.verifyOTP(otp: otpController.text);
    if (verified &&
        DateTime.now().difference(otpGeneratedTime!).inMinutes < 5) {
      if (newPasswordController.text == confirmNewPasswordController.text) {
        // print('----------verified------------');
        Navigator.of(context).pop();
        await changepass();
        Fluttertoast.showToast(
            msg: "PASSWORD CHANGED",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "Passwords do not match",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);

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
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.darkBrown, // Set the desired color
    ));
    final pHeight = MediaQuery.of(context).size.height;
    final pWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.lightSandal,
      appBar: AppBar(
        title: const Text('TCE DMDR WORKERS PORTAL',style: TextStyle(fontFamily: 'LexendDeca',fontWeight: FontWeight.bold,fontSize: 18),),
        backgroundColor: AppColors.darkBrown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: pHeight*0.10,),
              TextButton(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'New User? ',
                        style: TextStyle(
                          color: AppColors.darkBrown,
                          fontSize: 20,
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.bold,
                          height: 0,
                        ),
                      ),
                      TextSpan(
                        text: ' REGISTER',
                        style: TextStyle(
                          color: AppColors.darkBrown,
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          height: 0,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
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
              SizedBox(height: pHeight*0.05,),
              Container(
                height: pHeight*0.5,
                padding: EdgeInsets.only(top: 50),
                decoration: ShapeDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.65, -0.76),
                    end: Alignment(-0.65, 0.76),
                    colors: [Color(0xFFFACD84), Color(0xE2630000)],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 5,
                      offset: Offset(8, 9),
                      spreadRadius: 1,
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: pWidth*0.4,
                        height: pHeight*0.05,
                        child: Text(
                          'LOGIN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF630000),
                            fontSize: 35,
                            fontFamily: 'Monserrat',
                            fontWeight: FontWeight.bold,
                            height: 0.01,
                            letterSpacing: 3.50,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          focusNode: myFocusNode,
                          controller: emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFBEEFF),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            labelText: 'Email',
                            labelStyle: TextStyle(
                                color: myFocusNode.hasFocus ? AppColors.darkBrown : Colors.grey // Change the color as needed
                            ),
                            errorStyle: TextStyle(
                                color: AppColors.lightSandal
                            ),
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
                          focusNode: myFocusNode2,
                          obscureText: !passwordVisible,
                          controller: passwordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color(0xFFFBEEFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: myFocusNode2.hasFocus ? AppColors.darkBrown : Colors.grey, // Change the color as needed
                            ),
                            errorStyle: TextStyle(
                              color: AppColors.lightSandal
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                      ),
                      TextButton(
                        child: Text(
                          'Forgot password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'LexendDeca',
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            height: 0,
                          ),
                        ),
                        onPressed: () async {
                          if (emailController.text != "" && isValidEmail(emailController.text)) {
                            await generateOtpAndSendEmail();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder:
                                    (BuildContext context, StateSetter setState) {
                                  return AlertDialog(
                                    backgroundColor: AppColors.lightSandal,
                                    title: Text('CHANGE PASSWORD',style:TextStyle(fontFamily: 'Monserrat')),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min ,
                                      children: <Widget>[
                                        Text('OTP sent to ${emailController.text}',style:TextStyle(fontFamily: 'Inter',fontSize: 16)),
                                        TextField(
                                          controller: otpController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter OTP',
                                            hintStyle: TextStyle(color: Colors.brown,fontFamily: 'Inter'),
                                          ),
                                        ),
                                        SizedBox(height: pHeight*0.02,),
                                        TimerCountdown(
                                          format: CountDownTimerFormat.minutesSeconds,
                                          endTime:
                                              DateTime.now().add(Duration(minutes: 5)),
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
                                        SizedBox(height: pHeight*0.02,),
                                        TextField(
                                          controller: newPasswordController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter new password',
                                            hintStyle: TextStyle(color: Colors.brown,fontFamily: 'Inter'),
                                          ),
                                        ),
                                        TextField(
                                          controller: confirmNewPasswordController,
                                          decoration: InputDecoration(
                                            hintText: 'Confirm new password',
                                            hintStyle: TextStyle(color: Colors.brown,fontFamily: 'Inter'),
                                          ),
                                        ),
                                        SizedBox(height: pHeight*0.03),
                                        ElevatedButton(
                                          child: Text('Submit',style:TextStyle(fontFamily: 'Inter',fontSize: 16)),
                                          onPressed: () {
                                            verifyOtpAndChangePassword();
                                          },
                                          style: ElevatedButton.styleFrom(backgroundColor:AppColors.darkBrown,foregroundColor: Colors.white,shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0), // Adjust the value for the desired corner radius
                                          ),),
                                        ),
                                        SizedBox(height: pHeight*0.01,),
                                        TextButton(onPressed: (){Navigator.pop(context);}, child: Text('cancel',style:TextStyle(fontFamily: 'Inter',fontSize: 16)))
                                      ],
                                    ),
                                  );
                                });
                              },
                            );
                          } else {
                            FocusScope.of(context).unfocus();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fill email field with proper email'),
                              ),
                            );
                          }
                        },
                      ),
                      if (isLoading)
                        Center(
                          child: SpinKitFadingCircle(
                            color: AppColors.darkSandal,
                            size: pWidth*0.5,
                          ),
                        ),
                      Container(
                        width: pWidth*0.65,
                        height: pHeight*0.07,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 8,
                              backgroundColor: AppColors.darkSandal,
                              foregroundColor: AppColors.darkBrown
                              // You can customize other properties like padding, elevation, shape, etc.
                              ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              showLoadingDialog(context);
                              bool success = await handleLogin();
                              Navigator.pop(context); // Dismiss the dialog
                              if (success) {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                bool? notFirstTime = prefs.getBool('not_first_time');
                                if (notFirstTime != null && notFirstTime) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => HomePage(worker_id)),
                                  );
                                } else {
                                  prefs.setBool('not_first_time', true);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => Welcome()),
                                  );
                                }
                              }
                            }
                          },
                          child: const Text(
                            'LOGIN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF630000),
                              fontSize: 28,
                              fontFamily: 'NotoSans',
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
