import 'package:flutter/material.dart';

class Numpad extends StatefulWidget {
  final Function(String, String, String) onSubmit;
  final bool isChecked;
  final Map<String, dynamic> T1;

  Numpad({
    super.key,
    required this.onSubmit,
    required this.T1,
    required this.isChecked,
  });

  @override
  _NumpadState createState() => _NumpadState();
}

class _NumpadState extends State<Numpad> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _customernamecontroller = TextEditingController();
  final TextEditingController _customerphonecontroller =
      TextEditingController();
  PageController _pageController = PageController();

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // เมื่อ TextField ถูกโฟกัส
        print("TextField focused");
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fontSize = size.height * 0.02; // ขนาดฟอนต์ยืดหยุ่น
    final buttonHeight = size.height * 0.05; // ขนาดปุ่มยืดหยุ่น

    return PageView(
      controller: _pageController,
      children: [
        Column(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // TextField สำหรับจำนวนลูกค้า
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'จำนวนลูกค้า | Pax Qty',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      style: TextStyle(fontSize: fontSize * 1.0),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _buildNumpad()), // Numpad ยืดหยุ่นตามจอ
                ],
              ),
            ),

            // ปุ่มด้านล่าง
            Expanded(
              flex: 1, // เพิ่ม Expanded ให้ปุ่มยืดหยุ่น
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(
                            vertical:
                                buttonHeight * 0.6), // ใช้ขนาดปุ่มแบบยืดหยุ่น
                      ),
                      child: Text('ปิด | CANCEL',
                          style: TextStyle(fontSize: fontSize)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final inputValue = _controller.text;
                        if (inputValue.isNotEmpty) {
                          if (widget.isChecked) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            widget.onSubmit(inputValue, '', '');
                            Navigator.pop(context);
                          }
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: Colors.orange,
                                      size: fontSize * 1.0,
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                        'กรุณาป้อนจำนวนคน',
                                        style: TextStyle(fontSize: fontSize),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02,
                                  horizontal: size.width * 0.05,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            },
                          );

                          Future.delayed(const Duration(seconds: 2), () {
                            Navigator.of(context).pop(); // ปิด Dialog
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 0, 67, 122),
                        padding: EdgeInsets.symmetric(
                            vertical: buttonHeight * 0.6), // ปรับขนาดปุ่ม
                      ),
                      child: Text(
                        widget.isChecked ? 'ต่อไป | NEXT' : 'ยืนยัน | SUBMIT',
                        style: TextStyle(fontSize: fontSize),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // หน้า 2: Customer Name และ Phone
        Column(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // ชื่อลูกค้า
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _customernamecontroller,
                      decoration: InputDecoration(
                        hintText: 'ชื่อลูกค้า | Customer Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      style: TextStyle(fontSize: fontSize * 1.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // เบอร์โทรศัพท์ลูกค้า
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _customerphonecontroller,
                      decoration: InputDecoration(
                        hintText: 'เบอร์โทรศัพท์ลูกค้า | Customer Phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      style: TextStyle(fontSize: fontSize * 1.0),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  Expanded(
                    child: _buildNumpadphone(), // Numpad สำหรับเบอร์โทรศัพท์
                  ),
                ],
              ),
            ),

            // ปุ่มด้านล่าง
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(vertical: buttonHeight * 0.6),
                      ),
                      child: Text('กลับ | BACK',
                          style: TextStyle(fontSize: fontSize)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final inputValue = _controller.text;
                        final nameinputValue = _customernamecontroller.text;
                        final phoneinputValue = _customerphonecontroller.text;

                        widget.onSubmit(
                            inputValue, nameinputValue, phoneinputValue);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 0, 67, 122),
                        padding:
                            EdgeInsets.symmetric(vertical: buttonHeight * 0.6),
                      ),
                      child: Text('ยืนยัน | SUBMIT',
                          style: TextStyle(fontSize: fontSize)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Numpad สำหรับหน้าที่ 1
  Widget _buildNumpad() {
    final List<String> numpadButtons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'delete'
    ];

    final size = MediaQuery.of(context).size;
    final fontSize = size.height * 0.025;

    // กำหนดขนาดสูงสุดสำหรับปุ่ม
    final double maxButtonSize = 100.0; // ขนาดสูงสุดของปุ่มแต่ละอัน
    final double buttonSize = (size.width * 0.3).clamp(50.0, maxButtonSize);

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent:
              buttonSize, // ปรับขนาดปุ่มตามขนาดหน้าจอแต่ไม่เกิน maxButtonSize
          mainAxisSpacing: 4,
          crossAxisSpacing: 25,
          childAspectRatio: 1, // ทำให้ปุ่มเป็นสี่เหลี่ยมจัตุรัส
        ),
        itemCount: numpadButtons.length,
        itemBuilder: (context, index) {
          final buttonText = numpadButtons[index];
          return ElevatedButton(
            onPressed: () {
              if (buttonText == 'delete') {
                if (_controller.text.isNotEmpty) {
                  _controller.text = _controller.text
                      .substring(0, _controller.text.length - 1);
                }
              } else if (buttonText.isNotEmpty) {
                if (buttonText == '0' && _controller.text.isEmpty) {
                  return;
                }
                _controller.text += buttonText;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonText == 'delete'
                  ? Colors.red
                  : const Color.fromARGB(255, 0, 67, 122),
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Center(
              child: Text(
                buttonText == 'delete' ? 'ลบ' : buttonText,
                style: TextStyle(fontSize: fontSize * 1.2, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumpadphone() {
    final List<String> numpadButtons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '',
      '0',
      'delete'
    ];

    final size = MediaQuery.of(context).size;
    final fontSize = size.height * 0.025;

    // กำหนดขนาดสูงสุดสำหรับปุ่ม
    final double maxButtonSize = 100.0; // ขนาดสูงสุดของปุ่มแต่ละอัน
    final double buttonSize = (size.width * 0.3).clamp(50.0, maxButtonSize);

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent:
              buttonSize, // ปรับขนาดปุ่มตามขนาดหน้าจอแต่ไม่เกิน maxButtonSize
          mainAxisSpacing: 4,
          crossAxisSpacing: 25,
          childAspectRatio: 1, // ทำให้ปุ่มเป็นสี่เหลี่ยมจัตุรัส
        ),
        itemCount: numpadButtons.length,
        itemBuilder: (context, index) {
          final buttonText = numpadButtons[index];
          return ElevatedButton(
            onPressed: () {
              if (buttonText == 'delete') {
                if (_customerphonecontroller.text.isNotEmpty) {
                  _customerphonecontroller.text = _customerphonecontroller.text
                      .substring(0, _customerphonecontroller.text.length - 1);
                }
              } else if (buttonText.isNotEmpty) {
                // ตรวจสอบความยาวก่อนเพิ่มตัวเลข
                if (_customerphonecontroller.text.length < 13) {
                  _customerphonecontroller.text += buttonText;
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonText == 'delete'
                  ? Colors.red
                  : const Color.fromARGB(255, 0, 67, 122),
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
            ),
            child: Center(
              child: Text(
                buttonText == 'delete' ? 'ลบ' : buttonText,
                style: TextStyle(fontSize: fontSize * 1.2, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}
