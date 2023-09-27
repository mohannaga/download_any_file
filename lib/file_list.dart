import 'dart:io';

import 'package:dio/dio.dart';
import 'package:download_any_file/check_permission.dart';
import 'package:download_any_file/directory_path.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as Path;

class FileList extends StatefulWidget {
  FileList({super.key});

  @override
  State<FileList> createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  bool isPermission = false;
  var checkAllPermissions = CheckPermission();

  checkPermission() async {
    var permission = await checkAllPermissions.isStoragePermission();
    if (permission) {
      setState(() {
        isPermission = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  var dataList = [
    {
      "id": "2",
      "title": "file audio 1",
      "url":
          "https://d27v42mq6qh8uv.cloudfront.net/file-1650621422527-3.7.3+Amararamam+Roopakam_m.mp3"
    },
    {
      "id": "3",
      "title": "file audio 2",
      "url":
          "https://d27v42mq6qh8uv.cloudfront.net/file-1650621422527-3.7.3+Amararamam+Roopakam_m.mp3"
    },
    {
      "id": "4",
      "title": "file audio 3",
      "url":
          "https://d27v42mq6qh8uv.cloudfront.net/file-1650621422527-3.7.3+Amararamam+Roopakam_m.mp3"
    },
    {
      "id": "5",
      "title": "file audio 4",
      "url":
          "https://d27v42mq6qh8uv.cloudfront.net/file-1650621422527-3.7.3+Amararamam+Roopakam_m.mp3"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("File List"),
        ),
        body: isPermission
            ? ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (BuildContext context, int index) {
                  var data = dataList[index];
                  return TileList(
                    fileUrl: data['url']!,
                    title: data['title']!,
                  );
                })
            : TextButton(
                onPressed: () {
                  checkPermission();
                },
                child: const Text("Permission issue")));
  }
}

class TileList extends StatefulWidget {
  TileList({super.key, required this.fileUrl, required this.title});
  final String fileUrl;
  final String title;

  @override
  State<TileList> createState() => _TileListState();
}

class _TileListState extends State<TileList> {
  bool dowloading = false;
  bool fileExists = false;
  double progress = 0;
  String fileName = "";
  late String filePath;
  late CancelToken cancelToken;
  var getPathFile = DirectoryPath();

  startDownload() async {
    cancelToken = CancelToken();
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    setState(() {
      dowloading = true;
      progress = 0;
    });

    try {
      await Dio().download(widget.fileUrl, filePath,
          onReceiveProgress: (count, total) {
        setState(() {
          progress = (count / total);
        });
      }, cancelToken: cancelToken);
      setState(() {
        dowloading = false;
        fileExists = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        dowloading = false;
      });
    }
  }

  cancelDownload() {
    cancelToken.cancel();
    setState(() {
      dowloading = false;
    });
  }

  checkFileExit() async {
    var storePath = await getPathFile.getPath();
    filePath = '$storePath/$fileName';
    bool fileExistCheck = await File(filePath).exists();
    setState(() {
      fileExists = fileExistCheck;
    });
  }

  openfile() {
    OpenFile.open(filePath);
    print("fff $filePath");
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      fileName = Path.basename(widget.fileUrl);
    });
    checkFileExit();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey.shade100,
      child: ListTile(
          title: Text(widget.title),
          leading: IconButton(
              onPressed: () {
                fileExists && dowloading == false
                    ? openfile()
                    : cancelDownload();
              },
              icon: fileExists && dowloading == false
                  ? const Icon(
                      Icons.window,
                      color: Colors.green,
                    )
                  : const Icon(Icons.close)),
          trailing: IconButton(
              onPressed: () {
                fileExists && dowloading == false
                    ? openfile()
                    : startDownload();
              },
              icon: fileExists
                  ? const Icon(
                      Icons.save,
                      color: Colors.green,
                    )
                  : dowloading
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 3,
                              backgroundColor: Colors.grey,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.blue),
                            ),
                            Text(
                              "${(progress * 100).toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 12),
                            )
                          ],
                        )
                      : const Icon(Icons.download))),
    );
  }
}
