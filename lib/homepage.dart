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
  var _sortProperty = null; // default sorting property
  List<String> _sortProperties = ['due date', 'wage', 'subtasks'];
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
      _sortProperty = null;
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
          builder: (context) =>  MyHomePage(title: 'TCE DMDR')),
    );
  }

  void _sortWorks() {
    setState(() {
      switch (_sortProperty) {
        case 'due date':
          WorkNameList.sort((a, b) => DateTime.parse(a['due_date'])
              .compareTo(DateTime.parse(b['due_date'])));
          break;
        case 'wage':
          WorkNameList.sort((a, b) => b['wage'].compareTo(a['wage']));
          break;
        case 'subtasks':
          WorkNameList.sort((a, b) => b['total_subtasks'].compareTo(a['total_subtasks']));
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mediumBrown,
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
      body: isLoading
          ? Center(
              child: SpinKitFadingCircle(
                color: AppColors.darkSandal,
                size: 100.0,
              ),
            )
          : Column(
            children: [
              Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ColorFiltered(colorFilter: ColorFilter.mode(
                      AppColors.darkBrown.withOpacity(0.5), // Adjust the color and opacity as needed
                      BlendMode.srcATop,
                    ),child: Image.asset(AppImages.workers,fit: BoxFit.fill)),
                    Container(
                      padding: const EdgeInsets.all(20),
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
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20,0,20,20),
                  decoration: const BoxDecoration(
                    color: AppColors.lightSandal,
                    borderRadius:
                    BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      RefreshIndicator(
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
                                        IconButton(
                                          icon: Icon(Icons.refresh),
                                          onPressed: () {
                                            fetchData();
                                            setState(() {});
                                          },
                                        ),
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
                                    IconButton(
                                      icon: Icon(Icons.refresh),
                                      onPressed: () {
                                        fetchData();
                                        setState(() {});
                                      },
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "WORKS ASSIGNED..",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 50,
                                          width: 150,
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(248, 204, 29, 1.0),
                                              // Background color of dropdown button
                                              border: Border.all(
                                                  color: Colors.black38,
                                                  width: 3),
                                              // Border of dropdown button
                                              borderRadius:
                                              BorderRadius.circular(40),
                                              // Border radius of dropdown button
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.57),
                                                  // Shadow for button
                                                  blurRadius:
                                                  5, // Blur radius of shadow
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  vertical: 0,
                                                  horizontal: 10),
                                              child: DropdownButton<String>(
                                                alignment: AlignmentDirectional.center,
                                                value: _sortProperty, // This will be null initially
                                                items: <DropdownMenuItem<String>>[
                                                  DropdownMenuItem<String>(
                                                    value: null, // This item will not be selectable
                                                    child: Container(
                                                      padding:EdgeInsets.only(left: 10),
                                                      child: Text(
                                                        'Sort by',
                                                        style: TextStyle(color: AppColors.darkBrown, fontSize: 16),
                                                      ),
                                                    ),
                                                  ),
                                                  ..._sortProperties.map((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Center(
                                                        child: Text(
                                                          value,
                                                          style: TextStyle(color: AppColors.darkBrown, fontSize: 16),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ],
                                                onChanged: (String? newValue) {
                                                  if (newValue != null) { // Prevent updating the value if it's the "Sort by" item
                                                    setState(() {
                                                      _sortProperty = newValue;
                                                    });
                                                    _sortWorks();
                                                  }
                                                },
                                                hint: _sortProperty == null // This hint will be displayed when _sortProperty is null
                                                    ? Text(
                                                  'Sort by',
                                                  style: TextStyle(color: AppColors.darkBrown, fontSize: 16),
                                                )
                                                    : null,
                                                icon: Icon(Icons.arrow_drop_down, color: AppColors.darkBrown),
                                                iconSize: 34,
                                                dropdownColor: Color.fromRGBO(248, 204, 29, 1.0),
                                                isExpanded: true,
                                                underline: SizedBox(),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 20,),
                                    Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.separated(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        itemCount: WorkNameList.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.darkSandal,
                                              borderRadius: BorderRadius.circular(5), // Adjust the value for the desired corner radius
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              child: ListTile(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          WorkDescriptionPage(
                                                              WorkNameList[
                                                              index]),
                                                    ),
                                                  ).whenComplete(
                                                          () => fetchData());
                                                },
                                                title: Text(
                                                    "${WorkNameList[index]['work_name']}", style: TextStyle(
                                                  fontFamily: 'LexendDeca', // Replace 'YourFontFamily' with the desired font family
                                                  fontSize: 16, // Adjust the font size as needed
                                                  fontWeight: FontWeight.bold, // Specify the font weight if needed
                                                  // other text styling properties...
                                                ),),
                                                trailing:
                                                SimpleCircularProgressBar(
                                                  progressStrokeWidth: 5,
                                                  backStrokeWidth: 6,
                                                  size: 47,
                                                  mergeMode: true,
                                                  progressColors: const [
                                                    AppColors.darkBrown
                                                  ],
                                                  backColor:
                                                  Colors.white,
                                                  fullProgressColor:
                                                  Colors.green,
                                                  valueNotifier: ValueNotifier<
                                                      double>(WorkNameList[
                                                  index][
                                                  'completed_subtasks'] *
                                                      1.0),
                                                  onGetText: (double value) {
                                                    return Text(
                                                        '${value.toInt()}%');
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context,
                                            int index) {
                                          return Container(
                                            color: AppColors.mediumBrown,
                                            height: 5,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
