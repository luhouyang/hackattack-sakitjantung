import 'dart:isolate';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  String? getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  void initializeEventList() {
    currentUserUid = getCurrentUserUid();
    if (currentUserUid != null) {
      loadEventsFromFirebase();
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
      saveEventToFirebase(entity);
      notifyListeners();
      debugPrint("onData: ${event.toString()}");
    } else {
      debugPrint("Duplicate notification received: ${event.toString()}");
    }
  }

  void removeEvent(NotificationEvent event) {
    NotificationEventEntity entity = convertToEntity(event);

    eventsEntities.removeWhere((e) => e.uniqueId == entity.uniqueId);

    for (NotificationEventEntity e in eventsEntities) {
      debugPrint(e.text);
    }

    removeEventFromFirebase(entity);

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

  Future<void> createUserDocument(String uid) async {
    try {
      final firestore = FirebaseFirestore.instance;
      DocumentReference userDocRef = firestore.collection('users').doc(uid);

      if (!(await userDocRef.get()).exists) {
        await userDocRef.set({
          'uid': uid,
        });
      }
    } catch (error) {
      debugPrint('Error creating user document: $error');
    }
  }

  Future<void> saveEventToFirebase(NotificationEventEntity entity) async {
    if (currentUserUid == null) {
      debugPrint("User is not authenticated. Cannot save event.");
      return;
    }
    try {
      final firestore = FirebaseFirestore.instance;
      DocumentReference userDocRef =
          firestore.collection('users').doc(currentUserUid);
      CollectionReference eventsCollection = userDocRef.collection('events');

      await eventsCollection.add(entity.toMap());
      debugPrint('Event saved to Firebase: ${entity.toMap()}');
    } catch (error) {
      debugPrint('Error saving event to Firebase: $error');
    }
  }

  Future<void> removeEventFromFirebase(NotificationEventEntity entity) async {
    if (currentUserUid == null) {
      debugPrint("User is not authenticated. Cannot remove event.");
      return;
    }
    try {
      final firestore = FirebaseFirestore.instance;
      DocumentReference userDocRef =
          firestore.collection('users').doc(currentUserUid);
      CollectionReference eventsCollection = userDocRef.collection('events');

      QuerySnapshot querySnapshot = await eventsCollection
          .where('timestamp', isEqualTo: entity.timestamp)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        await document.reference.delete();
        uniqueEventIds.remove(entity.uniqueId);
        debugPrint('Event removed from Firebase: ${entity.toMap()}');
      }
    } catch (error) {
      debugPrint('Error removing event from Firebase: $error');
    }
  }

  Future<void> loadEventsFromFirebase() async {
    if (currentUserUid == null) {
      debugPrint("User is not authenticated. Cannot load events.");
      return;
    }
    try {
      eventsEntities.clear();

      final firestore = FirebaseFirestore.instance;
      DocumentReference userDocRef =
          firestore.collection('users').doc(currentUserUid);
      CollectionReference eventsCollection = userDocRef.collection('events');

      QuerySnapshot querySnapshot =
          await eventsCollection.orderBy('createAt').get();

      eventsEntities = querySnapshot.docs
          .map((DocumentSnapshot document) => NotificationEventEntity.fromMap(
              document.data() as Map<String, dynamic>))
          .toList();
      uniqueEventIds = eventsEntities.map((e) => e.uniqueId).toSet();
      debugPrint('Events loaded from Firebase: $eventsEntities');
    } catch (e) {
      debugPrint('Error loading events from Firebase: $e');
      rethrow;
    }
  }
}
