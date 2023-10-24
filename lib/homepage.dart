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

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('worker_id');
    await prefs.remove('isLoggedIn');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'TCE Work Management')),
    );
  }

  @override
  Widget build(BuildContext context) {
    int workerId = widget.worker_id;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.darkBrown,
          title: const Text("Agency/Contractor"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: logout,
            ),
          ],
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Image.asset(AppImages.workers),
            Container(
              padding: EdgeInsets.all(30),
              alignment: Alignment.topLeft,
              child: Text(
                "Greetings!!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 180),
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "WORKS ASSIGNED..",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(
                            () {}); // This will trigger a rebuild of the FutureBuilder
                      },
                      child: FutureBuilder(
                        future: getworks(workerId),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LinearProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            var WorkNameList = snapshot.data;
                            if (WorkNameList.isEmpty) {
                              return const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    "You have no works currently",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              );
                            } else {
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
                                                builder: (context) =>
                                                    WorkDescriptionPage(
                                                        WorkNameList[index]),
                                              ),
                                            ).then((_) {
                                              // This block runs when you have returned back to the 1st Page from 2nd.
                                              setState(() {
                                                // Call setState to refresh the page.
                                              });
                                            });
                                          },
                                          title: Text(
                                              "${WorkNameList[index]['work_name']}"),
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      color: Colors.white,
                                      height: 1,
                                    );
                                  },
                                ),
                              );
                            }
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
