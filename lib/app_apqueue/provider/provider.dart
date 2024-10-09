import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DataProvider with ChangeNotifier {
  String? _domainValue;
  String? _printerValue;
  String? _givenameValue;
  Color? _colorValue;

  String? get domainValue => _domainValue;
  String? get printerValue => _printerValue;
  String? get givenameValue => _givenameValue;
  Color? get colorValue => _colorValue;

  // ฟังก์ชันสำหรับโหลดค่าเริ่มต้นจาก Hive box แต่ละตัว
  Future<void> loadData() async {
    await _loadDomainData();
    await _loadPrintData();
    await _loadGiveNameData();
    await _loadColorData();
  }

  // โหลดข้อมูลจาก Hive box ชื่อ 'Domain'
  Future<void> _loadDomainData() async {
    var domainBox = await Hive.openBox('Domain');

    if (domainBox.containsKey('Domain')) {
      _domainValue = domainBox.get('Domain');
    } else {
      _domainValue = 'Default Domain';
      await domainBox.put('Domain', _domainValue);
    }

    notifyListeners();
  }

  // โหลดข้อมูลจาก Hive box ชื่อ 'User'
  Future<void> _loadPrintData() async {
    var PrinterDeviceBox = await Hive.openBox('PrinterDevice');

    if (PrinterDeviceBox.containsKey('PrinterDevice')) {
      _printerValue = PrinterDeviceBox.get('PrinterDevice');
    } else {
      _printerValue = 'Default PrinterDevice';
      await PrinterDeviceBox.put('PrinterDevice', _printerValue);
    }

    notifyListeners();
  }

  // ตั้งค่า ืีทยฟก
  Future<void> _loadGiveNameData() async {
    var GiveNameBox = await Hive.openBox('GiveNameBox');

    if (GiveNameBox.containsKey('GiveNameBox')) {
      _givenameValue = GiveNameBox.get('GiveNameBox');
    } else {
      _givenameValue = 'Default GiveNameBox';
      await GiveNameBox.put('GiveNameBox', _givenameValue);
    }

    notifyListeners();
  }

  // ตั้งค่า ืีทยฟก
  Future<void> _loadColorData() async {
    var ColorBox = await Hive.openBox('ColorBox');

    if (ColorBox.containsKey('ColorBox')) {
      _colorValue = ColorBox.get('ColorBox');
    } else {
      _colorValue = const Color(0xFF099FAF);
      await ColorBox.put('ColorBox', _colorValue);
    }

    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'Domain'
  Future<void> setDomainValue(String value) async {
    var domainBox = await Hive.openBox('Domain');
    _domainValue = value;
    await domainBox.put('Domain', value);
    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'User'
  Future<void> setPrinterValue(String value) async {
    var PrinterDeviceBox = await Hive.openBox('PrinterDevice');
    _printerValue = value;
    await PrinterDeviceBox.put('PrinterDevice', value);
    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'givename'
  Future<void> setGiveNameValue(String value) async {
    var GiveNameBox = await Hive.openBox('GiveNameBox');
    _givenameValue = value;
    await GiveNameBox.put('GiveNameBox', value);
    notifyListeners();
  }

  // ตั้งค่าใหม่ให้กับ Hive box ชื่อ 'colorbox'
  Future<void> setColorValue(Color value) async {
    var ColorBox = await Hive.openBox('ColorBox');
    _colorValue = value;
    await ColorBox.put('ColorBox', value);
    notifyListeners();
  }
}
