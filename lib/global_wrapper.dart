import 'package:flutter/material.dart';
import 'package:image_viewer/model.dart';
import 'package:image_viewer/shortcut.dart';
import 'package:image_viewer/view.dart';

class GlobalWrapperWidget extends StatefulWidget {
  final String? filePath;
  const GlobalWrapperWidget({super.key, this.filePath});

  @override
  State<GlobalWrapperWidget> createState() => _GlobalWrapperWidgetState();
}

class _GlobalWrapperWidgetState extends State<GlobalWrapperWidget> {
  final FileModel _model = FileModel();

  @override
  void initState() {
    super.initState();
    _model.initFile(widget.filePath);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FileModelProvider(
      model: _model,
      child: GlobalShortcutWrapper(
        child: Scaffold(
          body: ViewPage(filePath: widget.filePath)
        ),
      ),
    );
  }
}