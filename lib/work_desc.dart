import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tce_dmdr/main.dart';
import 'package:tce_dmdr/widgets/appColors.dart';
import 'package:tce_dmdr/widgets/appText.dart';
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
  bool isExpanded = false;

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
        return SingleChildScrollView(
          child: Container(
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
                    fontFamily: 'NotoSans'
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
                    hintStyle: TextStyle(fontFamily: 'Inter',fontSize: 18)
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBrown,foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // Adjust the value for the desired corner radius
                      ),
                    ),
                    onPressed: () async {
                      await handleQuery(workId, _messageController.text);
                      Navigator.of(context).pop();
                      Fluttertoast.showToast(
                          msg: "SENT SUCCESSFULLY",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 3,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 17.0);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: const Text('Submit',style:TextStyle(fontFamily: 'Inter')),
                    ),
                  ),
                ),
              ],
            ),
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
    final pHeight = MediaQuery.of(context).size.height;
    final pWidth = MediaQuery.of(context).size.width;

    String dateTime(String isoDate) {
      DateTime time = DateTime.parse(isoDate);
      String formattedDate = DateFormat('MMMM dd, y').format(time);

      return formattedDate;
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

    Future<String> advanceamt(int workid) async {
      var dio = Dio();
      try {
        var response = await dio.request(
          'https://dmdrtce.in/db/getpayments?workid=$workid',
          options: Options(
            method: 'GET',
          ),
        );
        if (response.statusCode == 200) {
          var payments = await (response.data);
          for (var payment in payments) {
            if (payment['payment_type'] == "A") {
              print(payment['paid_amount']);
              return payment['paid_amount'].toString();
            }
          }
        } else {
          print(response.statusMessage);
        }
      } catch (error) {
        print('Error: $error');
      }
      return ""; // Return an empty string as a default value
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

      Future<File> getImageFile(String path) async {
        return File(path);
      }
      bool proceed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: AppColors.lightSandal,
                title: Text('Upload work completion proofs',style:TextStyle(fontFamily: 'Montserrat',fontSize: pWidth*0.045)),
                content: Container(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            final List<XFile> images = await picker.pickMultiImage();
                            if (images != null && images.isNotEmpty) {
                              setState(() {
                                selectedImages!.addAll(images);
                              });
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(pHeight*0.015),
                            child: Text('Add from gallery',style:TextStyle(fontFamily: 'Inter',fontSize: pWidth*0.04)),
                          ),
                          style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0), // Adjust the value for the desired corner radius
                            ),
                  ),
                        ),
                        SizedBox(height:pHeight*0.02),
                        ElevatedButton(
                          onPressed: () async {
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.camera,
                            );
                            if (image != null) {
                              setState(() {
                                selectedImages!.add(image);
                              });
                            }
                          },
                          child: Padding(
                            padding: EdgeInsets.all(pHeight*0.015),
                            child: Text('Take a new photo',style:TextStyle(fontFamily: 'Inter',fontSize: pWidth*0.04)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkBrown,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0), // Adjust the value for the desired corner radius
                            ),
                          ),
                        ),
                        SizedBox(height:pHeight*0.02),
                        Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: selectedImages!.length > 0
                              ? selectedImages!
                              .map(
                                (image) => FutureBuilder<File>(
                              future: getImageFile(image.path),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.darkBrown, // Set the border color here
                                        width: 2.0, // Set the border width here
                                      ),
                                    ),
                                    child: Image.file(
                                      snapshot.data!,
                                      width: pWidth*0.3,
                                      height: pWidth*0.3,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }
                                else {
                                  return Container(width: pWidth*0.3,height: pWidth*0.3,color: Colors.grey,child: CircularProgressIndicator(),); // Placeholder or loading indicator
                                }
                              },
                            ),
                          )
                              .toList()
                              : [],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel',style:TextStyle(fontFamily: 'Inter',fontSize: pWidth*0.04)),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Proceed',style:TextStyle(fontFamily: 'Inter',fontSize: pWidth*0.04)),
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
        if(selectedImages!.isEmpty){
          return false;
        }
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
            margin: EdgeInsets.symmetric(horizontal: pWidth*0.05,vertical: pHeight*0.25),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [Image.asset(AppImages.pop_up), Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: pHeight*0.04,),
                   Text(
                    "Completed?",
                    style: TextStyle(
                      decorationThickness: 0.001,
                      color: AppColors.darkBrown,
                      fontSize: pWidth*0.075,
                      fontFamily: 'Montserrat'
                    ),
                  ),
                  SizedBox(height: pHeight*0.07,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBrown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // Adjust the value for the desired corner radius
                      ),
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
                            backgroundColor: AppColors.lightSandal,
                            title: const Text('Upload Status'),
                            content: Text(
                              uploadSuccess
                                  ? 'Uploaded successfully'
                                  : 'Upload failed',
                                style:TextStyle(fontFamily: 'Inter',fontSize: pWidth*0.04)),
                            actions: <Widget>[
                              TextButton(style: TextButton.styleFrom(
                            backgroundColor: AppColors.darkBrown,foregroundColor: Colors.white,
                          ),
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
                    child: Padding(
                      padding: EdgeInsets.all(pWidth*0.03),
                      child: Text("Upload Attachments",style:TextStyle(fontFamily: 'Inter',fontSize: pWidth*0.045)),
                    ),
                  ),
                  SizedBox(height: pHeight*0.03,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0), // Adjust the value for the desired corner radius
                        ),
                      backgroundColor: AppColors.darkBrown,
                      foregroundColor: Colors.white
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop(); // Close the dialog
                      print(task);
                      await updatecompletion(task['task_id'], task['weightage']);
                      setState(() {});
                    },
                    child: Padding(
                      padding: EdgeInsets.all(pWidth*0.03),
                      child: Text('Skip',style:TextStyle(fontFamily: 'Inter',fontSize: pWidth*0.045)),
                    ),
                  ),
                  SizedBox(height: pHeight*0.035,),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel',style:TextStyle(fontSize: pWidth*0.04)))
                ],
              ),]
            ),
          );
        },
      );
    }
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: AppColors.darkBrown, // Set the desired color
    ));

    return Scaffold(
      backgroundColor: Color.fromRGBO(250, 253, 255, 1),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: AppColors.darkBrown,
        foregroundColor: Colors.white,
        title: Tooltip(
          message: work['work_name'],
          child: Text(
            "${work['work_name']}",
            overflow: TextOverflow.ellipsis, // Optional: Handle overflow with ellipsis
            style: TextStyle(fontFamily: 'LexendDeca'),
          ),
          triggerMode: TooltipTriggerMode.tap,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottomPopup(context, int.parse(work['work_id']));
        },
        backgroundColor: AppColors.darkBrown,
        child: const Icon(Icons.announcement),
      ),
      body: Padding(
        padding: EdgeInsets.all(pWidth*0.055),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Work Description",
                style: TextStyle(fontSize: pWidth*0.044, fontWeight: FontWeight.bold,fontFamily: 'LexendDeca')),
            SizedBox(height: pHeight*0.008),
            Text("${work['work_description']}", style: TextStyle(fontSize: pWidth*0.043,fontFamily: 'LexendDeca')),
            SizedBox(height: pHeight*0.025),
            Text("Time Period",
                style: TextStyle(fontSize: pWidth*0.044, fontWeight: FontWeight.bold,fontFamily: 'LexendDeca')),
            SizedBox(height: pHeight*0.008),
            Text(
                "${dateTime(work['start_date'])} - ${dateTime(work['due_date'])}",
                style: TextStyle(
                    fontSize: pWidth*0.0425,
                    fontFamily: 'LexendDeca',
                    color:
                        DateTime.parse(work['due_date']).isAfter(DateTime.now())
                            ? Colors.green
                            : Colors.red)),
            SizedBox(height: pHeight*0.025),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Wage",
                        style: TextStyle(
                            fontSize: pWidth*0.044, fontWeight: FontWeight.bold,fontFamily: 'LexendDeca')),
                    SizedBox(height: pHeight*0.008),
                    Text("₹${work['wage']}", style: TextStyle(fontSize: pWidth*0.043,fontFamily: 'LexendDeca')),
                    SizedBox(height: pHeight*0.025),
                    Text("Advance Paid",
                        style: TextStyle(
                            fontSize: pWidth*0.044, fontWeight: FontWeight.bold,fontFamily: 'LexendDeca')),
                    SizedBox(height: pHeight*0.008),
                    (work['advance_paid']
                        ? FutureBuilder<String>(
                      future: advanceamt(int.parse(work['work_id'])),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            // Handle error
                            return Text("Error: ${snapshot.error}");
                          }
                          // Display the result
                          return Text("${work['advance_paid'] ? "Yes - ₹" : "No"} ${snapshot.data}",
                              style: TextStyle(fontSize: pWidth*0.043,fontFamily: 'LexendDeca'));
                        } else {
                          // Show a loading indicator while waiting for the Future to complete
                          return CircularProgressIndicator();
                        }
                      },
                    )
                        : Text("No", style: TextStyle(fontSize: pWidth*0.043,fontFamily: 'LexendDeca'))
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('Progress %',
                        style: TextStyle(
                            fontSize: pWidth*0.044, fontWeight: FontWeight.bold,fontFamily: 'LexendDeca')),
                    SizedBox(height: pHeight*0.02),
                    SimpleCircularProgressBar(
                      mergeMode: true,
                      progressColors: const [AppColors.darkBrown],
                      backColor: AppColors.darkSandal,
                      fullProgressColor: Colors.green,
                      valueNotifier: _progressNotifier,
                      size: pWidth*0.23,
                      onGetText: (double value) {
                        return Text('${value.toInt()}%',style: TextStyle(fontFamily: 'LexendDeca',fontWeight: FontWeight.bold,fontSize: pWidth*0.044),);
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: pHeight*0.01),
            Center(
                child: Text("Sub Tasks:",
                    style:
                        TextStyle(fontSize: pWidth*0.044, fontWeight: FontWeight.bold,fontFamily: 'LexendDeca'))),
            SizedBox(height: pHeight*0.005),
            Column(
              children: [
                Text(
                  "Weightage and importance level",
                  style: TextStyle(fontSize: pWidth*0.044,fontFamily: 'Inter',fontWeight: FontWeight.w500),
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
                                  width: pWidth*0.015, // Set your desired outer border width
                                )                   ),
                            width: pWidth*0.06,
                            height: pWidth*0.06
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
                                  width: pWidth*0.015, // Set your desired outer border width
                                )                   ),
                            width: pWidth*0.06,
                            height: pWidth*0.06
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
                              width: pWidth*0.015, // Set your desired outer border width
                            )                   ),
                          width: pWidth*0.06,
                          height: pWidth*0.06
                        ),
                        Text('High(>70%)'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: pHeight*0.02,),
            isLoading
                ? SpinKitFadingCircle(
                    color: AppColors.darkSandal,
                    size: pWidth*0.25,
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
                          return Material(
                            color: Color.fromRGBO(250, 253, 255, 1),
                            child: ReorderableListView.builder(
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
                                          width: pWidth*0.01, // Set your desired border width here
                                        ),
                                        borderRadius: BorderRadius.circular(8.0), // Set your desired border radius here
                                      ),
                                      child:
                                        Tooltip(
                                          message: "${task['weightage']} %",
                                          preferBelow: true,
                                          triggerMode: TooltipTriggerMode.longPress,
                                          child: ListTile(
                                            tileColor: const Color(0xFFFFEAC8),
                                            // key: ValueKey(task['task_id']),
                                            title: GestureDetector(onTap: () {
                                              setState(() {
                                                isExpanded = !isExpanded;
                                              });
                                            },child: Text(task['task_name'],
                                              maxLines: isExpanded ? null : 1,
                                              overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                              style: TextStyle(fontFamily: 'LexendDeca'),
                                            ),),
                                            subtitle: Text(
                                              "Due: ${dateTime(task['due_date'])}${DateTime.now().year == DateTime.parse(task['due_date']).year && DateTime.now().month == DateTime.parse(task['due_date']).month && DateTime.now().day == DateTime.parse(task['due_date']).day ? " \u203C" : ""}",
                                            style: TextStyle(fontFamily: 'Inter'),),
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
                                                    icon:  Icon(
                                                      Icons.check_box_outlined,
                                                      color: AppColors.darkBrown,
                                                      size: pWidth*0.08,
                                                    )),
                                            trailing: ReorderableDragStartListener(
                                              index: index,
                                              child: const Icon(Icons.drag_handle),
                                            ),
                                          ),
                                        ),
                                    ),
                                    Divider(height: pHeight*0.014,color: AppColors.darkBrown,)
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
                            ),
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
