import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:hive/hive.dart';
import 'package:sakitjantung/entities/noti_entity.dart';
import 'package:sakitjantung/services/alibaba_services.dart';
// import 'package:encrypt/encrypt.dart' as enc;

import '../services/firebase_services.dart';

class NotiListenerUseCase extends ChangeNotifier {
  List<NotificationEventEntity> eventsEntities = [];
  Set<String> uniqueEventIds = {};
  bool started = false;
  bool isLoading = false;
  bool isListening = false;
  ReceivePort port = ReceivePort();
  final FirebaseService firebaseService = FirebaseService();
  List<String> ignored = [
    "com.whatsapp",
    "com.tencent.mm",
    "org.telegram.messenger",
    "com.instagram.android",
    "com.facebook.orca",
    "com.microsoft.office.outlook",
    "com.discord"
  ];

  NotiListenerUseCase() {
    firebaseService.addListener(_firebaseServiceListener);
  }

  @override
  void dispose() {
    firebaseService.removeListener(_firebaseServiceListener);
    super.dispose();
  }

  void _firebaseServiceListener() {
    // Only notify listeners if the relevant data has actually changed
    if (eventsEntities != firebaseService.loadEventsFromFirebase()) {
      notifyListeners();
    }
  }

  Future<void> initializeEventList() async {
    await firebaseService.initializeUserUid();
    if (firebaseService.currentUserUid != null) {
      eventsEntities = await firebaseService.loadEventsFromFirebase();
      uniqueEventIds = eventsEntities.map((e) => e.uniqueId).toSet();
      notifyListeners();
    } else {
      debugPrint("User is not authenticated. Cannot load events.");
    }
  }

  @pragma('vm:entry-point')
  static void _callback(NotificationEvent evt) {
    debugPrint("send evt to ui: $evt");
    final SendPort? send = IsolateNameServer.lookupPortByName("_listener_");
    if (send == null) debugPrint("can't find the sender");
    send?.send(evt);
  }

  Future<void> initPlatformState() async {
    NotificationsListener.initialize(callbackHandle: _callback);

    IsolateNameServer.removePortNameMapping("_listener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");
    if (!isListening) {
      port.listen((message) async => await onData(message));
      isListening = true;
    }

    var isRunning = (await NotificationsListener.isRunning) ?? false;
    debugPrint("""Service is ${!isRunning ? "not " : ""}already running""");

    started = isRunning;
    notifyListeners();
  }

  // converts amounts
  List<double> extractAmounts(String message) {
    // Regular expression to match amounts with "RM" in various formats
    final RegExp regExp = RegExp(r'RM\s?(\d+(?:\.\d+)?)', caseSensitive: false);
    List<double> amounts = [];

    // Find all matches in the message
    Iterable<RegExpMatch> matches = regExp.allMatches(message);

    // Convert matches to double and add to the list
    for (var match in matches) {
      String? amountStr = match.group(1);
      if (amountStr != null) {
        amounts.add(double.parse(amountStr));
      }
    }

    return amounts;
  }

  Future<void> onData(NotificationEvent event) async {
    try {
      if (!uniqueEventIds.contains(event.timestamp.toString())) {
        NotificationEventEntity entity = convertToEntity(event);

        // if (!ignored.contains(entity.packageName)) {
        // check message
        String msg = "${entity.title} | ${entity.text}";
        debugPrint(msg);
        List<int> resList = await AlibabaServices().classifyData(msg);
        if (resList[0] == -1) {
          //TODO: replace with error message
          debugPrint("Connection Timed Out");
          return;
        } else if (resList[0] == 0) {
          notifyListeners();
          return;
        } else if (resList[0] == 1) {
          // money in
          entity.transactionType = resList[0];

          // extract amount
          double amount = extractAmounts(msg)[0];
          entity.amount = amount;
        } else if (resList[0] == 2) {
          // money out
          entity.transactionType = resList[0];

          // extract amount
          double amount = extractAmounts(msg)[0];
          entity.amount = amount;
        }

        if (resList[1] == -1) {
          //TODO: replace with error message
          debugPrint("Connection Timed Out");
          return;
        } else if (resList[1] == 5) {
          return;
        } else {
          // money in
          entity.transactionCategory = resList[1];
          eventsEntities.add(entity);
          uniqueEventIds.add(event.timestamp.toString());
          await firebaseService.saveEventToFirebase(entity);
          notifyListeners();
        }

        // }
        debugPrint("onData: ${event.toString()}");
      } else {
        debugPrint("Duplicate notification received: ${event.toString()}");
      }
    } catch (e) {
      debugPrint("Error on load data: $e");
    }
  }

  Future<void> removeEvent(NotificationEvent event, int index) async {
    NotificationEventEntity entity = convertToEntity(event);

    var box = await Hive.openBox("encryptionkey");

    List<String> keys = [];
    List<String> ivs = [];
    if (box.values.isNotEmpty) {
      keys = box.get('salsa20')!;
      ivs = box.get('iv')!;
      keys.removeAt(index);
      ivs.removeAt(index);
      box.deleteAll(['salsa20', 'iv']);
    }

    box.putAll({'salsa20': keys, 'iv': ivs});

    eventsEntities.removeWhere((e) => e.uniqueId == entity.uniqueId);
    uniqueEventIds.remove(entity.uniqueId);
    // await firebaseService.removeEventFromFirebase(entity);
    notifyListeners();
    debugPrint("Event removed");
  }

  void startListening() async {
    debugPrint("start listening");
    isLoading = true;
    notifyListeners();
    var hasPermission = (await NotificationsListener.hasPermission) ?? false;
    if (!hasPermission) {
      debugPrint("no permission, so open settings");
      NotificationsListener.openPermissionSettings();
      return;
    }

    var isRunning = (await NotificationsListener.isRunning) ?? false;

    if (!isRunning) {
      await NotificationsListener.startService(
        foreground: false,
        title: "Listener Running",
        description: "Welcome to having me",
      );
    }

    started = true;
    isLoading = false;
    notifyListeners();
  }

  void stopListening() async {
    debugPrint("stop listening");

    isLoading = true;
    notifyListeners();

    await NotificationsListener.stopService();

    started = false;
    isLoading = false;
    notifyListeners();
  }

  NotificationEventEntity convertToEntity(NotificationEvent event) {
    return NotificationEventEntity(
      uniqueId: event.uniqueId,
      key: event.key,
      packageName: event.packageName,
      uid: event.uid,
      channelId: event.channelId,
      id: event.id,
      createAt: event.createAt,
      timestamp: event.timestamp,
      title: event.title,
      text: event.text,
      canTap: event.canTap,
    );
  }

  NotificationEvent convertToEvent(NotificationEventEntity entity) {
    return NotificationEvent(
      uniqueId: entity.uniqueId,
      key: entity.key,
      packageName: entity.packageName,
      uid: entity.uid,
      channelId: entity.channelId,
      id: entity.id,
      createAt: entity.createAt,
      timestamp: entity.timestamp,
      title: entity.title,
      text: entity.text,
      canTap: entity.canTap,
    );
  }

  // loadEventsFromFirebase() {}
}
