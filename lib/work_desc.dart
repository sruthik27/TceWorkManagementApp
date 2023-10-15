import 'package:flutter/material.dart';
import 'package:work_management_app/widgets/appColors.dart';
import 'package:work_management_app/widgets/appText.dart';
import 'package:intl/intl.dart';

class WorkDescriptionPage extends StatefulWidget {
  final Map<String, dynamic> work_details;
  const WorkDescriptionPage(this.work_details, {super.key});

  @override
  State<WorkDescriptionPage> createState() => _WorkDescriptionPageState();
}

class _WorkDescriptionPageState extends State<WorkDescriptionPage> {
  @override
  Widget build(BuildContext context) {
    var work = widget.work_details;
    var progress = (work['completed_subtasks'] / work['total_subtasks']) * 100;
    // print(progress);
    String? dateTime(String isoDate) {
      DateTime time = DateTime.parse(isoDate);
      String formattedDate = DateFormat('MMMM dd, y').format(time);

      return formattedDate; // Output: October 15, 2023
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBrown,
        title: Text("${work['work_name']}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.HeadingText("Task Description"),
                    AppText.ContentText("${work['work_description']}"),
                    SizedBox(height: 20),
                    AppText.HeadingText("Time Period"),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        strokeWidth: 8,
                        backgroundColor: AppColors.lightSandal,
                        color: AppColors.mediumBrown,
                        value: 0.5,
                      ),
                    ),
                    AppText.HeadingText("50%"),
                  ],
                ),
              ],
            ),
            AppText.ContentText(
                "${dateTime(work['start_date'])} - ${dateTime(work['due_date'])}"),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppText.HeadingText("Total Wage:"),
                AppText.brownBoldText("${work['wage']}/-"),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppText.HeadingText("Advnc. Wage:"),
                AppText.brownBoldText("${work['advance_paid']}/-"),
              ],
            ),
            SizedBox(height: 20),
            AppText.HeadingText("Sub Tasks:"),
            SizedBox(height: 20),
            Expanded(
              child: Scrollbar(
                isAlwaysShown: true,
                child: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return InkWell(
                      child: Container(
                        color: AppColors.lightSandal,
                        child: ListTile(
                          onTap: () {
                            // print("${WorkNameList[index].runtimeType}");
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => WorkDescriptionPage(
                            //           WorkNameList[index])),
                            // );
                          },
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("sub tasks"),
                              Text("start-due"),
                              Icon(
                                Icons.check,
                              )
                            ],
                          ),
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
      ),
    );
  }
}
