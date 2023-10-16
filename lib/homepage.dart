import 'package:flutter/material.dart';
import 'package:work_management_app/work_desc.dart';
import '../main.dart';
import '../widgets/appColors.dart';
import '../widgets/appImages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_test.dart';

class HomePage extends StatefulWidget {
  final int worker_id;
  const HomePage(this.worker_id, {super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('worker_id');
    await prefs.remove('isLoggedIn');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: 'TCE Work Management')),
    );
  }

  @override
  Widget build(BuildContext context) {
    int worker_id = widget.worker_id;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkBrown,
          title: Text("Agency/Contractor"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: logout,
            ),
          ],
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset(AppImages.workers),
            Container(
              margin: EdgeInsets.only(top: 180),
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WORKS ASSIGNED..",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});  // This will trigger a rebuild of the FutureBuilder
                        },
                      child: FutureBuilder(
                        future: getworks(worker_id),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return LinearProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            var WorkNameList = snapshot.data;
                            if (WorkNameList.isEmpty) {
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    "You have no works currently",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                            }else{
                            return Scrollbar(
                              thumbVisibility: true,
                              child: ListView.separated(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: WorkNameList.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    child: Container(
                                      color: AppColors.darkSandal,
                                      child: ListTile(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => WorkDescriptionPage(
                                                  WorkNameList[index]
                                              ),
                                            ),
                                          );
                                        },
                                        title: Text("${WorkNameList[index]['work_name']}"),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) {
                                  return Container(
                                    color: Colors.white,
                                    height: 1,
                                  );
                                },
                              ),
                            );}
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
