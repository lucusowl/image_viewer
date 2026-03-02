import 'package:flutter/material.dart';
import 'package:image_viewer/view.dart';

void main(List<String> args) {
  String? initialFilePath;

  if (args.isNotEmpty) {
    // TEMP, 1st param
    initialFilePath = args[0];
  }

  runApp(ImageViewerApp(initialFilePath));
}

class ImageViewerApp extends StatelessWidget {
  final String? filePath;
  const ImageViewerApp(this.filePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Image Viewer",
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.amber, brightness: .dark),
        textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(backgroundColor: Colors.amber.withAlpha(20)))
      ),
      // debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ViewPage(filePath: filePath)
      )
    );
  }
}