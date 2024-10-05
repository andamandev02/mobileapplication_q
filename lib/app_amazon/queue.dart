import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'setting.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _value = '000';
  String? _errorLoadingImage;
  bool _isPlaying = false;
  List<File> imageList = [];
  List<File> logoList = [];
  Timer? _timer;
  final Duration _changeImageDuration = const Duration(seconds: 10);
  final PageController _pageController = PageController();
  Timer? _flashTimer;
  int _flashCount = 0;
  bool _isGreen = true;
  List<bool> isVideoList = []; // ใช้บูลเพื่อบอกว่าเป็นวิดีโอหรือไม่
  Map<int, bool> _videoStatuses = {}; // Track video statuses
  Color _textColor = const Color.fromARGB(255, 242, 255, 0);

  @override
  void initState() {
    super.initState();
    _requestExternalStoragePermission();
    loadLogoFromDrive();
    loadImagesFromDrive();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    // findUsbPath();
    // });
    startTimer();
  }

  void startTimer() {
    Timer.periodic(_changeImageDuration, (Timer timer) {
      if (_pageController.hasClients) {
        int currentPage = (_pageController.page?.toInt() ?? 0);
        int nextPage = currentPage + 1;
        if (nextPage >= imageList.length) {
          nextPage = 0;
        }

        if (isVideoList[currentPage]) {
          // Check if the current video is finished before transitioning
          if (_videoStatuses[currentPage] ?? false) {
            _pageController.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
            );
          }
        } else {
          // If not a video, transition to next page
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _checkvalue(String value) async {
    if (_isPlaying) {
      return;
    }
    if (value == '.') {
      setState(() {
        _isFieldEnabled = false;
      });
      if (_value == '000' || _value == '00' || _value == '0') {
        _focusNode.requestFocus();
        _textController.clear();
      } else {
        int currentValue = int.parse(_value);
        _value = (currentValue).toString().padLeft(3, '0');
        _playSound(_value);
      }
    } else if (value == '+') {
      setState(() {
        _isFieldEnabled = false;
      });
      _handlePlus();
    }
  }

  void _handlePlus() async {
    int currentValue = int.parse(_value);
    _value = (currentValue + 1).toString().padLeft(3, '0');
    _playSound(_value);
    _focusNode.requestFocus();
    _textController.clear();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
    stopTimer();
  }

  void stopTimer() {
    _timer?.cancel();
  }

  bool _isFieldEnabled = true;

  Future<void> _handleSubmit(String value) async {
    if (_isPlaying) {
      return;
    }
    setState(() {
      _isFieldEnabled = false;
    });
    if (value == '*') {
      _handleMultiply();
    } else if (int.tryParse(value) != null) {
      _handleNumericValue(value);
    } else if (value == '---') {
      _handleReset();
      setState(() {
        _isFieldEnabled = true;
      });
    } else if (value.startsWith('***')) {
      _handleModeChange(value);
      setState(() {
        _isFieldEnabled = true;
      });
    } else if (RegExp(r'[^\d+-.*/]').hasMatch(value)) {
      _handleInvalidCharacter();
      setState(() {
        _isFieldEnabled = true;
      });
      // } else if (value == '/*-+') {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => const SettingScreen()),
      //   );
    } else {
      _handleInvalidCharacter();
    }
  }

  Future<void> loadLogoFromDrive() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await _requestExternalStoragePermission();
    }
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw 'External storage directory not found';
    }
    String usbPath =
        // '${externalDir.parent.parent.parent.parent.parent.parent.path}/CF09-E67B/images';
        // '${externalDir.parent.parent.parent.parent.parent.parent.path}/DB1D-7C56/images';
        // '${externalDir.parent.parent.parent.parent.parent.parent.path}/1474-1882/images';
        // '${externalDir.parent.parent.parent.parent.parent.parent.path}/ESD-USB/images';
        // '${externalDir.parent.parent.parent.parent.parent.parent.path}/2627-6E53/images';
        // '/storage/1474-1882/logo';
        // '/storage/22A1-A3D7/logo';
        // '/storage/0500-5AD3/logo';
        '/mnt/usb/0500-5AD3/logo';
    if (usbPath == null) {
      throw 'USB path is null';
    }
    Directory usbDir = Directory(usbPath);
    if (!usbDir.existsSync()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          const duration = Duration(seconds: 2);
          Timer(duration, () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Text(
              'USB directory does not exist : $usbPath',
              style: const TextStyle(fontSize: 50),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
      throw 'USB directory does not exist';
    }

    List<FileSystemEntity> files = usbDir.listSync();

    if (files.isEmpty) {
      throw 'No files found in USB directory';
    }
    List<File> logoFiles = files.whereType<File>().toList();
    if (logoFiles.isEmpty) {
      throw 'No image files found in USB directory';
    }
    setState(() {
      logoList = logoFiles;
    });
  }

  Future<void> loadImagesFromDrive() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      throw 'External storage directory not found';
    }
    String usbPath = '/mnt/usb/0500-5AD3/images';
    if (usbPath.isEmpty) {
      throw 'USB path is null';
    }
    Directory usbDir = Directory(usbPath);
    if (!usbDir.existsSync()) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          const duration = Duration(seconds: 2);
          Timer(duration, () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            title: Text(
              'USB directory does not exist : $usbPath',
              style: const TextStyle(fontSize: 50),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
      throw 'USB directory does not exist';
    }

    List<FileSystemEntity> files = usbDir.listSync();
    if (files.isEmpty) {
      throw 'No files found in USB directory';
    }

    List<File> imageFiles = files.whereType<File>().toList();
    if (imageFiles.isEmpty) {
      throw 'No image files found in USB directory';
    }

    _detectFileTypes(imageFiles);

    setState(() {
      imageList = imageFiles;
    });
  }

  void _detectFileTypes(List<File> files) {
    isVideoList = files.map((file) {
      return file.path.endsWith('.mp4') || file.path.endsWith('.avi');
    }).toList();
  }

  Future<void> _requestExternalStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
    } else {
      setState(() {
        _errorLoadingImage = 'Permission denied for storage';
      });
    }
  }

  void _handleReset() {
    setState(() {
      _isFieldEnabled = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFieldEnabled) {
        _focusNode.requestFocus(); // ทำให้ TextField โฟกัส
        _textController.clear(); // ลบข้อความใน TextFiel
      }
    });
  }

  void _handleInvalidCharacter() {
    setState(() {
      _isFieldEnabled = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFieldEnabled) {
        _focusNode.requestFocus(); // ทำให้ TextField โฟกัส
        _textController.clear(); // ลบข้อความใน TextFiel
      }
    });
  }

  void _handleNumericValue(String value) async {
    _value = value.toString().padLeft(3, '0');
    if (_value.length > 3) {
      _value = _value.substring(0, 3);
    }
    _playSound(_value);
    _focusNode.requestFocus();
    _textController.clear();
  }

  void _startBlinking() {
    // หยุด Timer เดิมถ้ามี
    _timer?.cancel();

    // เริ่มสลับสี
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _textColor = _textColor == const Color.fromARGB(255, 242, 255, 0)
            ? const Color.fromARGB(255, 0, 0, 0)
            : const Color.fromARGB(255, 242, 255, 0);
      });
    });

    // หยุดการสลับสีหลังจากเวลา 5 วินาที และเปลี่ยนกลับเป็นสีเหลือง
    Timer(Duration(seconds: 3), () {
      _timer?.cancel(); // หยุด Timer
      setState(() {
        _textColor =
            const Color.fromARGB(255, 242, 255, 0); // เปลี่ยนกลับเป็นสีเหลือง
      });
    });
  }

  void _playSound(String value) async {
    try {
      var box = await Hive.openBox('ModeSounds');
      var values = box.values.toList();
      var mode = box.values.first;
      final trimmedString = value.toString();
      final numberString = trimmedString.replaceAll(RegExp('^0+'), '');
      try {
        _startBlinking();

        if (mode == '1') {
          await _audioPlayer.play(AssetSource('sound/bell.mp3'));
        } else if (mode == '2') {
          await _audioPlayer.play(AssetSource('sound/TH/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/TH/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }
        } else if (mode == '3') {
          await _audioPlayer.play(AssetSource('sound/EN/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/EN/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }
        } else if (mode == '4') {
          await _audioPlayer.play(AssetSource('sound/CN/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/CN/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }
        } else if (mode == '5') {
          await _audioPlayer.play(AssetSource('sound/TH/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/TH/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }

          await Future.delayed(const Duration(milliseconds: 100));
          await _audioPlayer.play(AssetSource('sound/EN/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/EN/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }
        } else if (mode == '6') {
          await _audioPlayer.play(AssetSource('sound/TH/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/TH/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }

          await Future.delayed(const Duration(milliseconds: 100));
          await _audioPlayer.play(AssetSource('sound/CN/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/CN/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }
        } else if (mode == '7') {
          await _audioPlayer.play(AssetSource('sound/EN/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/EN/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }

          await Future.delayed(const Duration(milliseconds: 100));
          await _audioPlayer.play(AssetSource('sound/CN/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/CN/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }
        } else if (mode == '8') {
          await _audioPlayer.play(AssetSource('sound/TH/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/TH/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }

          await Future.delayed(const Duration(milliseconds: 100));
          await _audioPlayer.play(AssetSource('sound/EN/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/EN/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }

          await Future.delayed(const Duration(milliseconds: 100));
          await _audioPlayer.play(AssetSource('sound/CN/pleasenumber.mp3'));
          await Future.delayed(const Duration(milliseconds: 1200));
          for (int i = 0; i < numberString.length; i++) {
            await _audioPlayer
                .play(AssetSource('sound/CN/${numberString[i]}.mp3'));
            if (i + 1 < numberString.length &&
                numberString[i] == numberString[i + 1]) {
              await _audioPlayer.onPlayerStateChanged.firstWhere(
                (state) => state == PlayerState.completed,
              );
            } else {
              await Future.delayed(const Duration(milliseconds: 650));
            }
          }
        } else {
          await _audioPlayer.play(AssetSource('sound/bell.mp3'));
        }

        setState(() {
          _isFieldEnabled = true;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isFieldEnabled) {
            _focusNode.requestFocus(); // ทำให้ TextField โฟกัส
            _textController.clear(); // ลบข้อความใน TextFiel
          }
        });
      } catch (e) {
        print("Error playing sound: $e");
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Error playing sound: $e'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } finally {
        _timer?.cancel();
        _isFieldEnabled = true;
      }
    } catch (e) {
      print("Error opening Hive box: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error opening Hive box: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
    _timer?.cancel();
  }

  void _handleMultiply() {
    print("เคลียค่า");
    setState(() {
      _value = '000';
      _isFieldEnabled = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFieldEnabled) {
        _focusNode.requestFocus(); // ทำให้ TextField โฟกัส
        _textController.clear(); // ลบข้อความใน TextFiel
      }
    });
  }

  void _handleModeChange(String value) async {
    String numberPart = value.substring(3);
    if (numberPart.isNotEmpty && int.tryParse(numberPart) != null) {
      await _addToHive(numberPart);
      var box = await Hive.openBox('ModeSounds');
      var mode = box.values.first;
      _showModeChangeDialog(mode);
    } else {
      _focusNode.requestFocus();
      _textController.clear();
    }
  }

  Future<void> _addToHive(String mode) async {
    var box = await Hive.openBox('ModeSounds');
    await box.put('mode', mode);
    await box.close();
    setState(() {});
  }

  void _showModeChangeDialog(String mode) {
    String title, content;
    switch (mode) {
      case '1':
        title = 'MODE 1 : Bell';
        content = '';
        break;
      case '2':
        title = 'MODE 2 : Calling voice - THAI';
        content = '';
        break;
      case '3':
        title = 'MODE 3 : Calling voice - ENGLISH';
        content = '';
        break;
      case '4':
        title = 'MODE 4 : Calling voice - CHINA';
        content = '';
        break;
      case '5':
        title = 'MODE 5 : Calling voice - THAI & ENGLISH';
        content = '';
        break;
      case '6':
        title = 'MODE 6 : Calling voice - THAI & CHINA';
        content = '';
        break;
      case '7':
        title = 'MODE 7 : Calling voice - ENGLISH & CHINA';
        content = '';
        break;
      case '8':
        title = 'MODE 8 : Calling voice - THAI & ENGLISH & CHINA';
        content = '';
        break;
      default:
        title = 'Bell';
        content = '';
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        const duration = Duration(seconds: 2);
        Timer(duration, () {
          Navigator.of(context).pop();
        });
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 50),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
    _focusNode.requestFocus();
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      },
      onDoubleTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingScreen()),
        );
      },
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                color: const Color.fromARGB(235, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Stack(
                      children: [
                        Opacity(
                          opacity: 0,
                          child: TextField(
                            controller: _textController,
                            onChanged: (value) {
                              _checkvalue(value);
                            },
                            onSubmitted: _handleSubmit,
                            autofocus: true,
                            focusNode: _focusNode,
                            decoration: const InputDecoration(
                              hintStyle: TextStyle(
                                fontSize: 1.0,
                                color: Color.fromARGB(235, 255, 255, 255),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d+-.*/]')),
                            ],
                            maxLines: 1,
                            enabled: _isFieldEnabled,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: screenSize.width *
                                0.10, // ปรับค่าให้เหมาะสมกับความต้องการ
                          ),
                          child: Align(
                            alignment: Alignment.center, // ชิดซ้าย
                            child: SizedBox(
                              height: screenSize.height * 0.3,
                              child: Center(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: logoList.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.file(
                                        logoList[index],
                                        fit: BoxFit.fitWidth,
                                        alignment: Alignment.center,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: screenSize.width *
                            0.025, // ปรับค่าให้เหมาะสมกับความต้องการ
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft, // ชิดซ้าย
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: screenSize.width * 0.8, // กำหนดขนาดสูงสุด
                          ),
                          child: Text(
                            'Order No.',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                              // fontFamily: 'DIGITAL',
                              fontSize: screenSize.width * 0.03,
                            ),
                            textAlign: TextAlign.left, // ชิดซ้าย
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.none,
                          child: Text(
                            _value.substring(0, 3),
                            style: TextStyle(
                              color: _textColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DIGITAL',
                              letterSpacing: _value.contains('1') ? 50.0 : 10.0,
                              fontSize: screenSize.width * 0.23,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imageList.length,
                itemBuilder: (context, index) {
                  final file = imageList[index];
                  final isVideo = isVideoList[index];

                  if (isVideo) {
                    return Container(
                      color: Colors.black,
                      child: VideoPlayerWidget(
                        file: file,
                        onVideoFinished: (finished) {
                          setState(() {
                            _videoStatuses[index] = finished;
                          });
                        },
                      ),
                    );
                  } else {
                    return Container(
                      color: Colors.black,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Image.file(
                          file,
                        ),
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

class VideoPlayerWidget extends StatefulWidget {
  final File file;
  final ValueChanged<bool>
      onVideoFinished; // Callback to notify when video is finished

  VideoPlayerWidget({required this.file, required this.onVideoFinished});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..setVolume(0.0)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            widget.onVideoFinished(true); // Notify that video is finished
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
