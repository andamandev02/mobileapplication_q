import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import '../url.dart';

class ClassQueue {
  IO.Socket? socket;

  // Method to initialize WebSocket connection
  Future<void> initializeWebSocket() async {
    if (socket == null || !socket!.connected) {
      _connect();
    }
  }

  void _connect() {
    socket = IO.io(
      SOCKET_IO_HOST,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setPath(SOCKET_IO_PATH)
          .setExtraHeaders({'Connection': 'upgrade', 'Upgrade': 'websocket'})
          .enableForceNew()
          .build(),
    );

    socket?.onConnect((_) {});

    socket?.onConnectError((err) {
      print('Connect Error: $err');
      // Handle connection error
    });

    socket?.onError((err) {
      print('Error: $err');
      // Handle socket error
    });

    socket?.connect();
  }

  void close() {
    if (socket != null) {
      socket?.disconnect();
      socket = null;
    }
  }

  static final StreamController<List<Map<String, dynamic>>>
      _controllerSearchQueue =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  static Stream<List<Map<String, dynamic>>> get searchQueueStream =>
      _controllerSearchQueue.stream;

  static final StreamController<List<Map<String, dynamic>>>
      _controllerQueueAll =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  static Stream<List<Map<String, dynamic>>> get callerQueueAllStream =>
      _controllerQueueAll.stream;

  static Future<void> queuelist({
    required BuildContext context,
    required String branchid,
    required Function(List<Map<String, dynamic>>) onSearchQueueLoaded,
  }) async {
    try {
      final queryParameters = {
        'branchid': branchid,
      };
      final uri = Uri.parse(
              'https://somboonqms.andamandev.com/api/v1/queue-mobile/search-queue')
          .replace(queryParameters: queryParameters);
      final response = await http.get(
        uri,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          List<Map<String, dynamic>> searchQueueList =
              (jsonData['data'] as List)
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
          _controllerSearchQueue.add(searchQueueList);
          onSearchQueueLoaded(searchQueueList);
        } else {
          onSearchQueueLoaded([]);
        }
      } else {
        onSearchQueueLoaded([]);
      }
    } catch (e) {
      onSearchQueueLoaded([]);
    }
  }

  static Future<void> CallerQueueAll({
    required BuildContext context,
    required String branchid,
    required Function(List<Map<String, dynamic>>) onCallerQueueAllLoaded,
  }) async {
    try {
      final queryParameters = {
        'branchid': branchid,
      };
      final uri = Uri.parse(
              'https://somboonqms.andamandev.com/api/v1/queue-mobile/caller-queue-all')
          .replace(queryParameters: queryParameters);
      final response = await http.get(
        uri,
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('data') && jsonData['data'] is List) {
          List<Map<String, dynamic>> CallerQueueAllList =
              (jsonData['data'] as List)
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
          _controllerQueueAll.add(CallerQueueAllList);
          onCallerQueueAllLoaded(CallerQueueAllList);
        } else {
          _controllerQueueAll.add([]);
          onCallerQueueAllLoaded([]);
        }
      } else {
        _controllerQueueAll.add([]);
        onCallerQueueAllLoaded([]);
      }
    } catch (e) {
      _controllerQueueAll.add([]);
      onCallerQueueAllLoaded([]);
    }
  }

  static void dispose() {
    _controllerSearchQueue.close();
    _controllerQueueAll.close();
  }
}
