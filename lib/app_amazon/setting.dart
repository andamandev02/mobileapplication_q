import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:external_path/external_path.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<String> _storagePaths = [];
  final TextEditingController _folderNameController = TextEditingController();
  String FolderNameSelected = '';

  @override
  void initState() {
    super.initState();
    _listStoragePaths();
    _loadFolderFromHive();
  }

  void _loadFolderFromHive() async {
    var box = await Hive.openBox('FolderUSB');
    String? FolderNameString = box.get('FolderUSB');

    setState(() {
      FolderNameSelected = FolderNameString ?? 'No folder selected';
    });

    // แสดง Snackbar หลังจาก setState เรียบร้อยแล้ว
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected folder: $FolderNameSelected'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _listStoragePaths() async {
    final List<String> paths = [];

    // ที่เก็บข้อมูลในเครื่อง
    final directory = await getApplicationDocumentsDirectory();
    paths.add(directory.path);

    try {
      final usbPaths = await ExternalPath.getExternalStorageDirectories();
      if (usbPaths.isNotEmpty) {
        paths.addAll(usbPaths);
      }
    } catch (e) {
      print("Error accessing USB storage: $e");
    }

    setState(() {
      _storagePaths = paths;
    });
  }

  Future<void> _addToHive(String folderName) async {
    var box = await Hive.openBox('FolderUSB');
    await box.put('folder', folderName);
    await box.close();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ทำการเลือกโฟลเดอร์แล้ว/*'),
        duration: Duration(seconds: 2),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _folderNameController,
              decoration: const InputDecoration(
                labelText: 'Selected Folder',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _storagePaths.length,
              itemBuilder: (context, index) {
                final path = _storagePaths[index];
                final folderName = path.split('/').last;

                return ListTile(
                  title: Text(folderName),
                  onTap: () async {
                    setState(() {
                      _folderNameController.text = folderName;
                    });

                    // ทำงานที่เป็น async นอก setState
                    await _addToHive(folderName);
                    var box = await Hive.openBox('FolderUSB');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
