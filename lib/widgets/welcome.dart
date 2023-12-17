import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      'View your works and all available work.\n Complete your tasks as per the given due date.';
    } else if (_counter == 1) {
      count =
      'Upload the proofs for your works and get verified.\nTrack your progress throughout the work.';
    } else if (_counter == 2) {
      count =
      'Ask any queries or feedback on your assigned work.';
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
    return Scaffold(
      backgroundColor: (Color.fromRGBO(45, 62, 95, 1)),
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
                    'TUTORIAL',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: pHeight * 0.04,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Merienda',
                    ),
                  ),
                ),
                Container(
                  height: (pHeight - mediaQuery.padding.top) * 0.55,
                  child: Image.asset(
                    'assets/$pics.png',
                    width: pWidth * 1,
                    height: pHeight * 0.2,
                    alignment: Alignment.center,
                  ),
                ),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Merienda',
                    fontSize: pHeight * 0.027,
                  ),
                  textAlign: TextAlign.left,
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
                    side: BorderSide(color: Colors.black, width: 3),
                  ),
                  child: Text(
                    'SKIP',
                    style: TextStyle(
                      fontSize: pHeight * 0.027,
                      color: Colors.white,
                      fontFamily: 'Merienda',
                    ),
                  ),
                  color: Colors.lightBlue,
                  textColor: Colors.white,
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
                          ? Color.fromRGBO(46, 207, 9, 1)
                          : Colors.transparent,
                      //green : grey
                      width: pWidth * 0.006,
                    ),
                    color: Color.fromRGBO(196, 196, 196, 1),
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
                          ? Color.fromRGBO(46, 207, 9, 1)
                          : Colors.transparent,
                      width: pWidth * 0.006,
                    ),
                    color: Color.fromRGBO(196, 196, 196, 1),
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
                          ? Color.fromRGBO(46, 207, 9, 1)
                          : Colors.transparent,
                      width: pWidth * 0.006,
                    ),
                    color: Color.fromRGBO(196, 196, 196, 1),
                    shape: BoxShape.circle,
                  ),
                ),
                MaterialButton(
                  padding: EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(48),
                    side: BorderSide(color: Colors.black, width: 3),
                  ),
                  child: Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: pHeight * 0.027,
                      color: Colors.white,
                      fontFamily: 'Merienda',
                    ),
                  ),
                  color: Color.fromRGBO(48, 230, 91, 1),
                  textColor: Colors.white,
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
