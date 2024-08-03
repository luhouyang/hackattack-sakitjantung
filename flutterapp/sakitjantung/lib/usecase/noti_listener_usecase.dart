import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:sakitjantung/entities/noti_entity.dart';

import '../services/firebase_services.dart';

class NotiListenerUseCase extends ChangeNotifier {
  List<NotificationEventEntity> eventsEntities = [];
  Set<String> uniqueEventIds = {};
  bool started = false;
  bool isLoading = false;
  bool isListening = false;
  ReceivePort port = ReceivePort();
  final FirebaseService firebaseService = FirebaseService();

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
      port.listen((message) => onData(message));
      isListening = true;
    }

    var isRunning = (await NotificationsListener.isRunning) ?? false;
    debugPrint("""Service is ${!isRunning ? "not " : ""}already running""");

    started = isRunning;
    notifyListeners();
  }

  void onData(NotificationEvent event) {
    if (!uniqueEventIds.contains(event.timestamp.toString())) {
      NotificationEventEntity entity = convertToEntity(event);
      eventsEntities.add(entity);
      uniqueEventIds.add(event.timestamp.toString());
      firebaseService.saveEventToFirebase(entity);
      notifyListeners();
      debugPrint("onData: ${event.toString()}");
    } else {
      debugPrint("Duplicate notification received: ${event.toString()}");
    }
  }

  void removeEvent(NotificationEvent event) {
    NotificationEventEntity entity = convertToEntity(event);
    eventsEntities.removeWhere((e) => e.uniqueId == entity.uniqueId);
    uniqueEventIds.remove(entity.uniqueId);
    firebaseService.removeEventFromFirebase(entity);
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
}
