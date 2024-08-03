import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:sakitjantung/entities/noti_entity.dart';

class NotiListenerUseCase extends ChangeNotifier {
  List<NotificationEventEntity> eventsEntities = [];
  Set<String> uniqueEventIds = {};
  bool started = false;
  bool isLoading = false;
  bool isListening = false;
  ReceivePort port = ReceivePort();
  String? currentUserUid;

  @pragma(
      'vm:entry-point') // prevent dart from stripping out this function on release build in Flutter 3.x
  static void _callback(NotificationEvent evt) {
    debugPrint("send evt to ui: $evt");
    final SendPort? send = IsolateNameServer.lookupPortByName("_listener_");
    if (send == null) debugPrint("can't find the sender");
    send?.send(evt);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    NotificationsListener.initialize(callbackHandle: _callback);

    // this can fix restart<debug> can't handle error
    IsolateNameServer.removePortNameMapping("_listener_");
    IsolateNameServer.registerPortWithName(port.sendPort, "_listener_");
    // Check if the port is already listening
    if (!isListening) {
      port.listen((message) => onData(message));
      isListening = true;
    }

    // don't use the default receivePort
    // NotificationsListener.receivePort.listen((evt) => onData(evt));

    var isRunning = (await NotificationsListener.isRunning) ?? false;
    debugPrint("""Service is ${!isRunning ? "not " : ""}already running""");

    started = isRunning;
    notifyListeners();
  }

  //Add Data
  void onData(NotificationEvent event) {
    if (!uniqueEventIds.contains(event.timestamp.toString())) {
      NotificationEventEntity entity = convertToEntity(event);
      eventsEntities.add(entity);
      uniqueEventIds.add(event.timestamp.toString());
      notifyListeners();
      debugPrint("onData: ${event.toString()}");
    } else {
      debugPrint("Duplicate notification received: ${event.toString()}");
    }
  }

  void removeEvent(NotificationEvent event) {
    NotificationEventEntity entity = convertToEntity(event);

    // Remove the event from the list by uniqueId
    eventsEntities.removeWhere((e) => e.uniqueId == entity.uniqueId);

    // Log the remaining events for debugging
    for (NotificationEventEntity e in eventsEntities) {
      debugPrint(e.text);
    }
    // Notify listeners to update the UI
    notifyListeners();

    debugPrint("Event removed");
  }

  Future<List<NotificationEventEntity>> loadEvents() async {
    // You can add any additional logic to fetch or process events here
    return eventsEntities;
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
