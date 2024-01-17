import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
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
  var WorkNameList = [];
  String _sortProperty = 'due_date'; // default sorting property
  List<String> _sortProperties = ['due_date', 'wage', 'total_subtasks'];
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    fetchData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed from minimized state");
      fetchData();
    }
  }

  void fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });
      WorkNameList = await getworks(widget.worker_id);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('worker_id');
    await prefs.remove('isLoggedIn');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => const MyHomePage(title: 'TCE DMDR')),
    );
  }

  void _sortWorks() {
    setState(() {
      switch (_sortProperty) {
        case 'due_date':
          WorkNameList.sort((a, b) => DateTime.parse(a['due_date']).compareTo(DateTime.parse(b['due_date'])));
          break;
        case 'wage':
          WorkNameList.sort((a, b) => DateTime.parse(a['wage']).compareTo(DateTime.parse(b['wage'])));
          break;
        case 'total_subtasks':
          WorkNameList.sort((a, b) => DateTime.parse(a['total_subtasks']).compareTo(DateTime.parse(b['total_subtasks'])));
          break;
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBrown,
        foregroundColor: Colors.white,
        title: const Text("TCE DMDR Platform"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: isLoading?
    Center(
        child: SpinKitFadingCircle(
        color: AppColors.darkSandal,
    size: 100.0,
        ),
        ):Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset(AppImages.workers),
          Container(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Text(
                  "Greetings from TCE!!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Text(
                    "\"வினையே உயிர்\"",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:16,
                  ),
                ),
              ],
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
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(
                              () {}); // This will trigger a rebuild of the FutureBuilder
                    },
                    child: FutureBuilder(
                      future: Future.value(WorkNameList),
                      builder:
                          (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          WorkNameList = snapshot.data;
                          if (WorkNameList.isEmpty) {
                            return Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "You have no works currently",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Column(
                              children: [
                                IconButton(icon: Icon(Icons.refresh), onPressed: (){
                                  fetchData();
                                  setState(() {
                                  });
                                },),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "WORKS ASSIGNED..",
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text('Sort by:'),
                                        DropdownButton<String>(
                                          alignment: AlignmentDirectional.bottomStart,
                                          value: _sortProperty,
                                          items: _sortProperties.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _sortProperty = newValue!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Scrollbar(
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
                                              ).whenComplete(() => fetchData());
                                            },
                                            title: Text(
                                                "${WorkNameList[index]['work_name']}"),
                                            trailing: SimpleCircularProgressBar(
                                              progressStrokeWidth: 5,
                                              backStrokeWidth: 6,
                                              size: 40,
                                              mergeMode: true,
                                              progressColors: const [AppColors.darkBrown],
                                              backColor: AppColors.lightSandal,
                                              fullProgressColor: Colors.green,
                                              valueNotifier: ValueNotifier<double>(WorkNameList[index]['completed_subtasks']*1.0),
                                              onGetText: (double value) {
                                                return Text('${value.toInt()}%');
                                              },
                                            ),
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
                                ),
                              ],
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
    );
  }
}
