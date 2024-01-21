import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tce_dmdr/widgets/appColors.dart';

import 'main.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final ScrollController _scrollController = ScrollController();
  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // Dispose of the ScrollController when not needed
    _scrollController.dispose();
    super.dispose();
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
        title: Text('Privacy Policy'),
        backgroundColor: AppColors.darkBrown,
        foregroundColor: AppColors.lightSandal,
      ),
      body: Scrollbar(
        thickness: 6,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Privacy Policy for TCE DMDR App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(Icons.arrow_circle_down,size: 42,),
                  onPressed: () {
                    scrollToBottom();
                  },
                ),
              ),
              SizedBox(height: pHeight*0.01),
              _buildSectionTitle('Introduction'),
              _buildSectionContent(
                  'This privacy policy applies to the TCE DMDR App, which is designed to manage third party works at Thiagarajar college of engineering. This app is provided by TCE and is responsible for protecting your privacy.'
              ),
              _buildSectionTitle('Information We Collect'),
              _buildSectionContent(
                  'We collect the following information from you when you register and use the app:\n'
                      '- Email address: This is used to create your account, allow you to log in, and reset your password if needed.\n'
                      '- Phone number: This is used to contact you if we have any questions or need to provide updates about your work.'
              ),
              _buildSectionTitle('How We Use Information'),
              _buildSectionContent('We use the information we collect to:\n- Assign and manage work for agencies\n- Track progress and completion of work\n- Facilitate communication between the college and agencies\n- Verify work completion with photo proofs\n- Send notifications about work assignments and updates\n- Sharing Information\nWe do not share your personal information with any third parties outside of TCE.'),
              _buildSectionTitle('Data Retention'),
              _buildSectionContent('We retain your personal information for as long as you are actively working with TCE. Once you no longer work with us, your data will be deleted from our systems within a reasonable period.'),
             _buildSectionTitle('Security'),
              _buildSectionContent('We take security seriously and use a variety of measures to protect your personal information from unauthorized access, use, or disclosure. These measures include: Secure databases,Encrypted transmission of data,Access controls,User Rights'),
              _buildSectionTitle('Compliance'),
              _buildSectionContent('We comply with all applicable data privacy laws and regulations.'),
              SizedBox(height: pHeight*0.01),
              _buildSectionContent('By clicking continue you agree to the privacy policy of TCE DMDR'),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Text('Agree & Continue',style: TextStyle(fontFamily: 'Inter',fontSize: 18),),
                  onPressed: () async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setBool('isFirst', true);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(title: 'TCE DMDR'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor:AppColors.darkBrown,foregroundColor: Colors.white,shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0), // Adjust the value for the desired corner radius
                  ),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
