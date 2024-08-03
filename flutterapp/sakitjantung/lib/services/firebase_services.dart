import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sakitjantung/entities/noti_entity.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? currentUserUid;

  Future<void> initializeUserUid() async {
    currentUserUid = await getCurrentUserUid();
    notifyListeners();
  }

  Future<String?> getCurrentUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  Future<void> createUserDocument(String uid) async {
    try {
      DocumentReference userDocRef = firestore.collection('users').doc(uid);

      if (!(await userDocRef.get()).exists) {
        await userDocRef.set({
          'uid': uid,
        });
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Error creating user document: $error');
    }
  }

  Future<void> saveEventToFirebase(NotificationEventEntity entity) async {
    enc.Key? key;
    enc.IV? iv;

    var box = await Hive.openBox("encryptionkey");
    // if (box.values.isEmpty) {
    //   key = enc.Key.fromLength(32);
    //   iv = enc.IV.fromLength(8);
    //   box.put('salsa20', key.base64);
    //   box.put('iv', iv.base64);
    //   debugPrint("Generating Key");
    // } else {
    //   key = enc.Key.fromBase64(box.get('salsa20')!);
    //   iv = enc.IV.fromBase64(box.get('iv')!);
    // }
    debugPrint("Generating Key");
    key = enc.Key.fromLength(32);
    iv = enc.IV.fromLength(8);

    List<String> keys = [];
    List<String> ivs = [];
    if (box.values.isNotEmpty) {
      keys = box.get('salsa20')!;
      ivs = box.get('iv')!;
      box.deleteAll(['salsa20', 'iv']);
    }

    keys.add(key.base64);
    ivs.add(iv.base64);

    box.putAll({'salsa20': keys, 'iv': ivs});

    final encrypter = enc.Encrypter(enc.Salsa20(key));
    final encrypted = encrypter.encrypt(entity.text, iv: iv);
    debugPrint(encrypted.base64);

    entity.text = encrypted.base64;

    if (currentUserUid == null) {
      debugPrint("User is not authenticated. Cannot save event.");
      return;
    }
    try {
      DocumentReference userDocRef =
          firestore.collection('users').doc(currentUserUid);
      CollectionReference eventsCollection = userDocRef.collection('events');

      await eventsCollection.add(entity.toMap());
      debugPrint('Event saved to Firebase: ${entity.toMap()}');
      notifyListeners();
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
      DocumentReference userDocRef =
          firestore.collection('users').doc(currentUserUid);
      CollectionReference eventsCollection = userDocRef.collection('events');

      QuerySnapshot querySnapshot = await eventsCollection
          .where('timestamp', isEqualTo: entity.timestamp)
          .get();

      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        await document.reference.delete();
        debugPrint('Event removed from Firebase: ${entity.toMap()}');
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Error removing event from Firebase: $error');
    }
  }

  Future<List<NotificationEventEntity>> loadEventsFromFirebase() async {
    //TODO: changed here
    if (getCurrentUserUid().toString().isEmpty) {
      debugPrint("User is not authenticated. Cannot load events.");
      return [];
    }
    try {
      DocumentReference userDocRef =
          firestore.collection('users').doc(currentUserUid);
      CollectionReference eventsCollection = userDocRef.collection('events');

      QuerySnapshot querySnapshot =
          await eventsCollection.orderBy('createAt').get();

      List<NotificationEventEntity> events = querySnapshot.docs
          .map((DocumentSnapshot document) => NotificationEventEntity.fromMap(
              document.data() as Map<String, dynamic>))
          .toList();

      debugPrint('Events loaded from Firebase: $events');
      return events;
    } catch (e) {
      debugPrint('Error loading events from Firebase: $e');
      rethrow;
    }
  }
}
