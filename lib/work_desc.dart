import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:work_management_app/main.dart';
import 'package:work_management_app/widgets/appColors.dart';
import 'package:work_management_app/widgets/appText.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'widgets/appImages.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:intl/intl.dart';

int completed = 0;
ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0);

class WorkDescriptionPage extends StatefulWidget {
  final Map<String, dynamic> work_details;

  const WorkDescriptionPage(this.work_details, {super.key});

  @override
  State<WorkDescriptionPage> createState() => _WorkDescriptionPageState();
}

class _WorkDescriptionPageState extends State<WorkDescriptionPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();
  List<XFile>? selectedImages;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  Future<void> handleQuery(int work, String message) async {
    final jsonData = {
      'work': work,
      'message': message,
      'who': 'W',
    };

    final dio = Dio();
    final response = await dio.post(
      'https://tcedmdrportal.onrender.com/db/addquery',
      // Replace with your actual API endpoint
      data: jsonData,
      options: Options(
        contentType: Headers.jsonContentType,
      ),
    );

    if (response.statusCode == 200) {
      print('Response: ${response.data}');
    } else {
      print('Error: ${response.statusMessage}');
    }
  }

  void _showBottomPopup(BuildContext context, int workId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: AppColors.lightSandal,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Share any update or ask queries:',
                style: TextStyle(
                  color: AppColors.darkBrown,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _messageController,
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                    color: AppColors.darkBrown,
                  )),
                  hintText: 'Enter your message here',
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                  ),
                  onPressed: () async {
                    await handleQuery(workId, _messageController.text);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    var work = widget.work_details;
    setState(() {
      completed += work['completed_subtasks'] as int;
      print("${completed}");
      _progressNotifier.value += completed;
    });
  }

  @override
  void dispose() {
    super.dispose();
    completed = 0;
    _progressNotifier = ValueNotifier<double>(0);
  }

  @override
  Widget build(BuildContext context) {
    var work = widget.work_details;
    int total = work['total_subtasks'];
    String dateTime(String isoDate) {
      DateTime time = DateTime.parse(isoDate);
      String formattedDate = DateFormat('MMMM dd, y').format(time);

      return formattedDate; // Output: October 15, 2023
    }

    Future<List<Map<String, dynamic>>> gettasks(int workid) async {
      var dio = Dio();
      var response = await dio.request(
        'https://tcedmdrportal.onrender.com/db/gettasks?n=$workid',
        options: Options(
          method: 'GET',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        return jsonData.cast<Map<String, dynamic>>();
      } else {
        print(response.statusMessage);
        return [];
      }
    }

    Future<void> changeorder(String taskId, int newOrder) async {
      var dio = Dio();
      var response = await dio.request(
        'https://tcedmdrportal.onrender.com/db/updateorder?task_id=$taskId&new_order=$newOrder',
        options: Options(
          method: 'PUT',
        ),
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));
      } else {
        print(response.statusMessage);
      }
    }

    Future<Uint8List> compressImage(XFile image) async {
      final Uint8List compressedImage =
          await FlutterImageCompress.compressWithList(
        await image.readAsBytes(),
        minWidth: 1000,
        minHeight: 1000,
        quality: 65,
      );
      String formattedDateTime =
          DateFormat("yyyy-MM-dd @ HH:mm").format(DateTime.now());
      // Add the timestamp watermark to the image
      final Uint8List watermarkedImage = await ImageWatermark.addTextWatermark(
        imgBytes: compressedImage,
        watermarkText: formattedDateTime,
        color: AppColors.darkBrown,
        dstX: 5,
        dstY: 5,
      );

      return watermarkedImage;
    }

    Future<String> uploadImage(XFile image) async {
      // Compress the image
      Uint8List compressedImage = await compressImage(image);

      // Create a reference to the location you want to upload to in Firebase Storage
      Reference ref =
          FirebaseStorage.instance.ref().child('images/${image.name}');

      // Upload the compressed image to Firebase Storage
      UploadTask uploadTask = ref.putData(compressedImage);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() async {
        // Get the download URL of the uploaded file
        String downloadURL = await ref.getDownloadURL();
        print('Image URL: $downloadURL');
      });

      // Return the download URL
      return await ref.getDownloadURL();
    }

    Future<void> addimageurl(String id, String url) async {
      final dio = Dio();

      final requestData = {
        'id': id,
        'url': url,
      };

      try {
        final response = await dio.put(
          'https://tcedmdrportal.onrender.com/db/appendimage',
          options: Options(
            method: 'PUT',
            headers: {
              Headers.contentTypeHeader: 'application/json',
            },
          ),
          data: requestData,
        );

        if (response.statusCode == 200) {
          print(response.data);
        } else {
          print(response.statusMessage);
        }
      } catch (e) {
        print('Error: $e');
      }
    }

    Future<void> updatecompletion(String taskId, int taskWeight) async {
      var dio = Dio();
      var response = await dio.request(
        'https://tcedmdrportal.onrender.com/db/updatetaskcompletion?task_id=$taskId',
        options: Options(
          method: 'PUT',
        ),
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));
        setState(() {
          completed += taskWeight;
          print(completed);
          _progressNotifier.value = completed * 1.0;
        });
        print(_progressNotifier.value);
      } else {
        print(response.statusMessage);
      }
    }

    //pt of failure
    Future<bool> pickImages() async {
      setState(() {
        selectedImages = [];
      });
      bool proceed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Text('Choose an option'),
                content: Container(
                  width: double.maxFinite,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final List<XFile> images =
                              await picker.pickMultiImage();
                          if (images != null && images.isNotEmpty) {
                            setState(() {
                              selectedImages!.addAll(images);
                            });
                          }
                        },
                        child: Text('Select from gallery'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera);
                          if (image != null) {
                            setState(() {
                              selectedImages!.add(image);
                            });
                          }
                        },
                        child: Text('Take a new photo'),
                      ),
                      Wrap(
                          spacing: 5.0, // gap between adjacent chips
                          runSpacing: 5.0, // gap between lines
                          children: selectedImages!.length > 0
                              ? selectedImages!.map((image) {
                                  return Image.file(
                                    File(image.path),
                                    width: 50, // width of the image
                                    height: 50, // height of the image
                                    fit: BoxFit.cover,
                                  );
                                }).toList()
                              : []),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Proceed'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
        },
      );

      if (proceed == true) {
        setState(() {
          isLoading = true;
        });
        for (XFile image in selectedImages!) {
          String url = await uploadImage(image);
          print('Image URL: $url');
          await addimageurl(work['work_id'], url);
        }
      }
      return proceed == true;
    }

    Future<void> showUploadPhotoDialog(BuildContext context, task) async {
      bool uploadSuccess = false;

      showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.pop_up),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  work['work_name'],
                  style: const TextStyle(
                    decorationThickness: 0.001,
                    color: AppColors.darkBrown,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  "Completed?",
                  style: TextStyle(
                    decorationThickness: 0.001,
                    color: AppColors.darkBrown,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    try {
                      bool uploaded = await pickImages();
                      if (uploaded) {
                        uploadSuccess = true;
                        await updatecompletion(
                            task['task_id'], task['weightage']);
                        setState(() {});
                      }
                    } catch (e) {
                      print('Error: $e');
                      uploadSuccess = false;
                    } finally {
                      setState(() {
                        isLoading = false;
                      });
                    }
                    showDialog(
                      context: _scaffoldKey.currentContext!,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Upload Status'),
                          content: Text(
                            uploadSuccess
                                ? 'Uploaded successfully'
                                : 'Upload failed',
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Close the status dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text("Upload Attachments"),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    print(task);
                    await updatecompletion(task['task_id'], task['weightage']);
                    setState(() {});
                  },
                  child: const Text('Skip'),
                ),
                const SizedBox(height: 20),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'))
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.darkBrown,
        foregroundColor: Colors.white,
        title: Text("${work['work_name']}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomPopup(context, int.parse(work['work_id']));
        },
        backgroundColor: AppColors.darkBrown,
        child: const Icon(Icons.announcement),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Work Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("${work['work_description']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text("Time Period",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
                "${dateTime(work['start_date'])} - ${dateTime(work['due_date'])}",
                style: TextStyle(
                    fontSize: 16,
                    color:
                        DateTime.parse(work['due_date']).isAfter(DateTime.now())
                            ? Colors.green
                            : Colors.red)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Wage",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("₹${work['wage']}", style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Text("Advance Paid",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Text("${work['advance_paid'] ? "Yes" : "No"}",
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Text('Progress %',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    SimpleCircularProgressBar(
                      mergeMode: true,
                      progressColors: const [AppColors.darkBrown],
                      backColor: AppColors.darkSandal,
                      fullProgressColor: Colors.green,
                      valueNotifier: _progressNotifier,
                      onGetText: (double value) {
                        return Text('${value.toInt()}%');
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
                child: Text("Sub Tasks:",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            SizedBox(height: 20),
            Column(
              children: [
                Text(
                  "Weightage and importance level",
                  style: TextStyle(fontSize: 18),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.green, // Set your desired outer border color
                                  width: 7.0, // Set your desired outer border width
                                )                   ),
                            width: 25,
                            height: 25
                        ),
                        Text('Low(< 30%)'),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.orange, // Set your desired outer border color
                                  width: 7.0, // Set your desired outer border width
                                )                   ),
                            width: 25,
                            height: 25
                        ),
                        Text('Medium(<70%)'),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red, // Set your desired outer border color
                              width: 7.0, // Set your desired outer border width
                            )                   ),
                          width: 25,
                          height: 25
                        ),
                        Text('High(>70%)'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            isLoading
                ? SpinKitFadingCircle(
                    color: AppColors.darkSandal,
                    size: 100.0,
                  )
                : Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: gettasks(int.parse(work['work_id'])),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return ReorderableListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var task = snapshot.data![index];
                              return Column(
                                key: ValueKey(task['task_id']),
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: task['weightage'] < 30
                                            ? Colors.green
                                            : task['weightage'] < 70
                                            ? Colors.orange
                                            : Colors.red,
                                        width: 3.0, // Set your desired border width here
                                      ),
                                      borderRadius: BorderRadius.circular(8.0), // Set your desired border radius here
                                    ),
                                    child:
                                      Tooltip(
                                        message: "${task['weightage']} %",
                                        preferBelow: true,
                                        triggerMode: TooltipTriggerMode.tap,
                                        child: ListTile(
                                          tileColor: const Color(0xFFFFEAC8),
                                          // key: ValueKey(task['task_id']),
                                          title: Text(task['task_name']),
                                          subtitle: Text(
                                            "Due: ${dateTime(task['due_date'])}${DateTime.now().year == DateTime.parse(task['due_date']).year && DateTime.now().month == DateTime.parse(task['due_date']).month && DateTime.now().day == DateTime.parse(task['due_date']).day ? " \u203C" : ""}",
                                          ),
                                          leading: task['completed']
                                              ? Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius:
                                                        BorderRadius.circular(15),
                                                  ),
                                                  child: const Text(
                                                    'Done',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : IconButton(
                                                  onPressed: () async {
                                                    await showUploadPhotoDialog(
                                                        context, task);
                                                  },
                                                  icon: const Icon(
                                                    Icons.check_circle,
                                                    color: AppColors.darkBrown,
                                                    size: 30,
                                                  )),
                                          trailing: ReorderableDragStartListener(
                                            index: index,
                                            child: const Icon(Icons.drag_handle),
                                          ),
                                        ),
                                      ),
                                  ),
                                  SizedBox(height: 6,)
                                ],
                              );
                            },
                            onReorder: (oldIndex, newIndex) async {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final Map<String, dynamic> item =
                                    snapshot.data!.removeAt(oldIndex);
                                snapshot.data!.insert(newIndex, item);
                              });

                              // Store all the changeorder requests in a list
                              List<Future> requests = [];
                              for (int i = 0; i < snapshot.data!.length; i++) {
                                requests.add(changeorder(
                                    snapshot.data![i]['task_id'], i));
                              }

                              // Wait for all the requests to finish
                              await Future.wait(requests);

                              // Then call gettasks again to refresh the list
                              setState(() {});
                            },
                          );
                        }
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
