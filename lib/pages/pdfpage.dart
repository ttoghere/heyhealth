import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:heyhealth/shared/loading.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String loc;
  PdfViewerPage({this.url, this.loc});
  @override
  _PdfViewerPageState createState() => _PdfViewerPageState(url, loc);
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String repurl;
  String reploc;
  String localPath;
  _PdfViewerPageState(repurl, reploc);

  Future<String> loadPDF(url, loc) async {
    var status = await Permission.storage.status;
    print(status);
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    var response = await http.get(url);

    var tempDir = await getApplicationDocumentsDirectory();
    //final fullPath = tempDir.path + '$loc';
    File file = new File("${tempDir.path}/report.pdf"); //new File(fullPath);
    file.writeAsBytesSync(response.bodyBytes, flush: true);
    return file.path;
  }

  @override
  void initState() {
    reploc = (widget.loc);
    repurl = (widget.url);
    super.initState();
    var url = Uri.parse(repurl);
    print(url);

    loadPDF(url, reploc).then((value) {
      setState(() {
        localPath = value;
        // print(localPath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "heyhealth patient Report",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: localPath != null
          ? PDFView(
              filePath: localPath,
              onError: (error) {
                print(error.toString());
              },
            )
          : Center(child: Loading()),
    );
  }
}
