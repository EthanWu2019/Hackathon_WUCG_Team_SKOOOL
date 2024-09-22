import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';  // 添加颜色选择器
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, Color> groupColors;
  final Function(String, Color) onColorChanged;

  SettingsPage({required this.groupColors, required this.onColorChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _icsLinkController = TextEditingController();
  File? _uploadedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 调整 Group 颜色块
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Adjust Group Color',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            widget.groupColors.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.groupColors.keys.length,
              itemBuilder: (context, index) {
                String groupName = widget.groupColors.keys.elementAt(index);
                Color currentColor = widget.groupColors[groupName]!;

                return ListTile(
                  title: Text(groupName),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: currentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: () {
                    _pickColor(context, groupName, currentColor);
                  },
                );
              },
            )
                : Center(
              child: Text('No groups available. Please add events to see groups.'),
            ),
            // 上传区域块
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Import',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // ICS 链接输入框和提交按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _icsLinkController,
                      decoration: InputDecoration(
                        labelText: 'Please enter a link in.ics format',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // 添加间距
                  ElevatedButton(
                    onPressed: () {
                      // 此处可以添加处理 ICS 链接的逻辑
                      print('ICS 链接: ${_icsLinkController.text}');
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
            // 上传 syllabus 文件
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: _selectFile,
                child: Text('Select and Upload Syllabus'),
              ),
            ),
            if (_uploadedFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('已选择文件: ${_uploadedFile!.path.split('/').last}'),
              ),
            // About Us 板块
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'About Us',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '制作人名单：\n'
                    'Chengze Wu\n'
                    'Xingshi Feng\n'
                    'Jack Yang\n'
                    'Jana Yan',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                '技术栈：\n'
                    '- Flutter (Dart)\n'
                    '- Table Calendar\n'
                    '- File Picker\n'
                    '- Flutter Color Picker\n'
                    '- Path Provider\n'
                    '- HTTP Library\n'
                    'Beta Version 0.0.1',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickColor(BuildContext context, String groupName, Color currentColor) {
    Color tempColor = currentColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pick a color for $groupName'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    pickerColor: tempColor,
                    onColorChanged: (Color color) {
                      setState(() {
                        tempColor = color;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Selected Color',
                    style: TextStyle(fontSize: 16),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: tempColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  widget.onColorChanged(groupName, tempColor); // 实时更新 group 的颜色
                });
                Navigator.of(context).pop();
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  // 用户选择文件方法
  void _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _uploadedFile = File(result.files.single.path!);
      });
    }
  }
}
