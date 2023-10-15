import 'package:flutter/material.dart';
import 'package:work_management_app/work_desc.dart';
import '../main.dart';
import '../widgets/appColors.dart';
import '../widgets/appImages.dart';

import 'api_test.dart';

class HomePage extends StatefulWidget {
  final int worker_id;
  const HomePage(this.worker_id, {super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var WorkNameList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getworks(worker_id).then((workers) {
      print("=============\n${workers}");
      // print("222222222222222222222222222222222222222222\n");
      // workers.forEach((element) {
      //   print(element['work_name']);
      // });
      setState(() {
        WorkNameList = workers;
        //   workers.forEach((element) {
        //     WorkNameList.append(element['work_name']);
        //   });
      });
    }).catchError((error) {
      print("Error: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    int worker_id = widget.worker_id;
    // List Workers = WorkersList;
    // print("11111111111111111111111111111111111111111111111\n");
    // print(WorkNameList[1].runtimeType);
    return Scaffold(
      // backgroundColor:   ,
      appBar: AppBar(
        backgroundColor: AppColors.darkBrown,
        title: Text("Agency/Contractor"),
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
                  child: Scrollbar(
                    isAlwaysShown: true,
                    child: ListView.separated(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: WorkNameList!.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          child: Container(
                            color: AppColors.darkSandal,
                            child: ListTile(
                              onTap: () {
                                // print("${WorkNameList[index].runtimeType}");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WorkDescriptionPage(
                                          WorkNameList[index])),
                                );
                              },
                              title:
                                  Text("${WorkNameList[index]['work_name']}"),
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
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
