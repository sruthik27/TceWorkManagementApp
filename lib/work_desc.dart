import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:work_management_app/widgets/appColors.dart';
import 'package:work_management_app/widgets/appText.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';



class WorkDescriptionPage extends StatefulWidget {
  final Map<String, dynamic> work_details;

  const WorkDescriptionPage(this.work_details, {super.key});

  @override
  State<WorkDescriptionPage> createState() => _WorkDescriptionPageState();
}

class _WorkDescriptionPageState extends State<WorkDescriptionPage> {

  final TextEditingController _messageController = TextEditingController();

  Future<void> handleQuery(int work, String message) async {
    final jsonData = {
      'work': work,
      'message': message,
      'who': 'W',
    };

    final dio = Dio();
    final response = await dio.post(
      'https://tceworkmanagement.azurewebsites.net/db/addquery', // Replace with your actual API endpoint
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
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Enter your message:'),
              TextField(
                controller: _messageController,
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Enter your message here',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await handleQuery(workId, _messageController.text);
                  Navigator.of(context).pop();
                },
                child: Text('Submit'),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var work = widget.work_details;
    var progress = (work['completed_subtasks'] / work['total_subtasks']);
    // print(progress);
    String dateTime(String isoDate) {
      DateTime time = DateTime.parse(isoDate);
      String formattedDate = DateFormat('MMMM dd, y').format(time);

      return formattedDate; // Output: October 15, 2023
    }

    Future<List<Map<String, dynamic>>> gettasks(int workid) async {
      var dio = Dio();
      var response = await dio.request(
        'https://tceworkmanagement.azurewebsites.net/db/gettasks?n=$workid',
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

    Future<void> changeorder(String task_id, int new_order) async {
      var dio = Dio();
      var response = await dio.request(
        'https://tceworkmanagement.azurewebsites.net/db/updateorder?task_id=${task_id}&new_order=$new_order',
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
      final Uint8List? compressedImage = await FlutterImageCompress.compressWithList(
        await image.readAsBytes(),
        minWidth: 1000,
        minHeight: 1000,
        quality: 65,
      );
      return compressedImage!;
    }



    Future<String> uploadImage(XFile image) async {
      // Compress the image
      Uint8List compressedImage = await compressImage(image);

      // Create a reference to the location you want to upload to in Firebase Storage
      Reference ref = FirebaseStorage.instance.ref().child('images/${image.name}');

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
          'https://tceworkmanagement.azurewebsites.net/db/appendimage',
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

    Future<void> updatecompletion(String task_id) async {
      var dio = Dio();
      var response = await dio.request(
        'https://tceworkmanagement.azurewebsites.net/db/updatetaskcompletion?task_id=$task_id',
        options: Options(
          method: 'PUT',
        ),
      );

      if (response.statusCode == 200) {
        print(json.encode(response.data));
      }
      else {
        print(response.statusMessage);
      }
    }


    List<XFile>? selectedImages;
    final ImagePicker _picker = ImagePicker();

    Future<void> pickImages() async {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null) {
        selectedImages = images;
        for (XFile image in selectedImages!) {
          String url = await uploadImage(image);
          print('Image URL: $url');
          await addimageurl(work['work_id'], url);
        }
      } else {
        print('No images were selected.');
        throw Exception('No images were selected');
      }
    }


    Future<void> showUploadPhotoDialog(BuildContext context,task) async {
      bool uploadSuccess = false;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attach proof of completion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Upload photo'),
                  onTap: () async {
                    Navigator.of(context).pop(); // Close the dialog

                    try {
                      await pickImages();
                      uploadSuccess = true;
                      await updatecompletion(task['task_id']);
                      setState(() {});
                    } catch (e) {
                      print('Error: $e');
                      uploadSuccess = false;
                    }
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Upload Status'),
                          content: Text(
                            uploadSuccess ? 'Uploaded successfully' : 'Upload failed',
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the status dialog
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: Text('Skip'),
                  onTap: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    await updatecompletion(task['task_id']);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      );
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.darkBrown,
        title: Text("${work['work_name']}"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomPopup(context, int.parse(work['work_id']));
        },
        child: Icon(Icons.announcement),
        backgroundColor: Colors.green,
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
                        value: progress,
                      ),
                    ),
                    AppText.HeadingText("${(progress * 100).toStringAsFixed(1)}%"),
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
                AppText.brownBoldText("₹${work['wage']}"),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AppText.HeadingText("Advnc Paid?"),
                AppText.brownBoldText("${work['advance_paid']}"),
              ],
            ),
            SizedBox(height: 20),
            AppText.HeadingText("Sub Tasks:"),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: gettasks(int.parse(work['work_id'])),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return ReorderableListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var task = snapshot.data![index];
                        return ListTile(
                          key: ValueKey(task['task_id']),
                          title: Text(task['task_name']),
                          subtitle: Text("Due: " + dateTime(task['due_date'])),
                          leading: task['completed']
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Text(
                                    'Done',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  onPressed: () async {
                                    await showUploadPhotoDialog(context,task);
                                  },
                                  icon: Icon(
                                    Icons.task_alt,
                                    color: Colors.green,
                                  )),
                          trailing: ReorderableDragStartListener(
                            index: index,
                            child: Icon(Icons.drag_handle),
                          ),
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
                          requests.add(
                              changeorder(snapshot.data![i]['task_id'], i));
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
