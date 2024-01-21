import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tce_dmdr/widgets/appColors.dart';

import '../homepage.dart';
import '../main.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  int _counter = 0;
  void _increaseCounter() {
    if (_counter > 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(worker_id)),
      );
    } else {
      setState(() {
        _counter = _counter + 1;
      });
    }
  }

  String get text {
    var count = '';
    if (_counter == 0) {
      count =
      '✅ View your works and allocated tasks.\n\n ✅ Track your progress on active works.';
    } else if (_counter == 1) {
      count =
      '✅ Update completion of each task. \n\n ✅ Upload image proofs for your completed works.';
    } else if (_counter == 2) {
      count =
      '✅ Reorder subtasks\n\n✅ Ask any queries \n\n✅ Report problems';
    }
    return count;
  }

  String get pics {
    var symbol = '';
    if (_counter == 0) {
      symbol = 'home';
    } else if (_counter == 1) {
      symbol = 'downloads';
    } else if (_counter == 2) {
      symbol = 'favs';
    }
    return symbol;
  }

  @override
  Widget build(BuildContext context) {
    final pHeight = MediaQuery.of(context).size.height;
    final mediaQuery = MediaQuery.of(context);
    final pWidth = MediaQuery.of(context).size.width;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.darkBrown, // Set the desired color
    ));
    return Scaffold(
      backgroundColor: AppColors.lightSandal,
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: pWidth * 0.01, vertical: pHeight * 0.01),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                  EdgeInsets.only(right: pWidth * 0.4, top: pHeight * 0.04),
                  child: Text(
                    'WELCOME',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: pHeight * 0.04,
                      color: AppColors.darkBrown,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LexcendDeca',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    height: (pHeight - mediaQuery.padding.top) * 0.50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30), // Adjust the value for the desired corner radius
                      color: AppColors.darkSandal, // Your desired background color
                    ),
                    child: Image.asset(
                      'assets/$pics.png',
                      width: pWidth * 1,
                      height: pHeight * 0.2,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    text,
                    style: TextStyle(
                      color: AppColors.darkBrown,
                      fontFamily: 'Merienda',
                      fontSize: pHeight * 0.027,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MaterialButton(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                    side: BorderSide(color: AppColors.darkBrown, width: 3),
                  ),
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                      fontSize: pHeight * 0.027,
                      color: AppColors.mediumBrown,
                      fontFamily: 'Merienda',
                    ),
                  ),
                  color: AppColors.darkSandal,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(worker_id)),
                    );
                  },
                ),
                Container(
                  height: (pHeight - mediaQuery.padding.top) * 0.1,
                  width: pWidth * 0.05,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _counter == 0
                          ? AppColors.darkBrown
                          : Colors.transparent,
                      //green : grey
                      width: pWidth * 0.006,
                    ),
                    color: AppColors.darkSandal,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: pWidth * 0.039),
                Container(
                  height: (pHeight - mediaQuery.padding.top) * 0.1,
                  width: pWidth * 0.05,
                  alignment: AlignmentDirectional.bottomCenter,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _counter == 1
                          ? AppColors.darkBrown
                          : Colors.transparent,
                      width: pWidth * 0.006,
                    ),
                    color: AppColors.darkSandal,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: pWidth * 0.039),
                Container(
                  height: (pHeight - mediaQuery.padding.top) * 0.1,
                  width: pWidth * 0.05,
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _counter == 2
                          ? AppColors.darkBrown
                          : Colors.transparent,
                      width: pWidth * 0.006,
                    ),
                    color: AppColors.darkSandal,
                    shape: BoxShape.circle,
                  ),
                ),
                MaterialButton(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                    side: BorderSide(color: AppColors.darkBrown, width: 3),
                  ),
                  child: Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: pHeight * 0.027,
                      color: AppColors.mediumBrown,
                      fontFamily: 'Merienda',
                    ),
                  ),
                  color: AppColors.darkSandal,
                  onPressed: _increaseCounter,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
