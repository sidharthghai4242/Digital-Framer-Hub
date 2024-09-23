import 'dart:async';
import 'dart:io';
import 'package:digital_farmer_hub/models/ReportModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../helper/loaderWidget.dart';
import '../helper/theme_class.dart';

class PDFViewer extends StatefulWidget {
  final String title;
  final String pdfUrl;

  const PDFViewer({
    Key? key,
    required this.title,
    required this.pdfUrl,
  }) : super(key: key);

  @override
  State<PDFViewer> createState() => _PDFViewerState();
}

class _PDFViewerState extends State<PDFViewer> {
  String pathPDF = "";
  late File file;

  @override
  void initState() {
    super.initState();
    createFileOfPdfUrl().then((f) {
      setState(() {
        pathPDF = f!.path;
        print(pathPDF);
      });
    });
  }

  Future<File?> createFileOfPdfUrl() async {
    final url = widget.pdfUrl;
    const filename = "temp.pdf";
    var request = await HttpClient().getUrl(Uri.parse(url??""));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getTemporaryDirectory()).path;
    file = File('$dir/$filename');
    await file!.writeAsBytes(bytes);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text(
          widget!.title!,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: ThemeClass.colorPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
        body: (pathPDF??"").isEmpty ? Container(
          alignment: const Alignment(0, 0),
          child: const Center(child: CircularProgressIndicator()),
        ):PDFView(filePath: pathPDF,)
    );
  }
}
