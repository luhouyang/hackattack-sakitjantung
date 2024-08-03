import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
    if (currentUserUid == null) {
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
