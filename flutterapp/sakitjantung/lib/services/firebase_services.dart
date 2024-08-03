import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:sakitjantung/entities/noti_entity.dart';

class FirebaseService extends ChangeNotifier {
  List<NotificationEventEntity> dummyData = [
    NotificationEventEntity(
        title: "Transfer Successful.",
        text: "RM 10.00 has been successfully transfereed to BEN LOO.",
        amount: 10.00,
        transactionType: 1,
        transactionCategory: 4),
    NotificationEventEntity(
        title: "Payment To: Golden Screen Cinemas Sdn Bhd ",
        text:
            "Golden Screen Cinemas Sdn Bhd: RM19.00 has been deducted from you TNG eWallet.",
        amount: 19.00,
        transactionType: 1,
        transactionCategory: 1),
    NotificationEventEntity(
        title: "Payment To: McD KAMPAR",
        text:
            "McD KAMPAR: RM22.50 has been deducted from you TNG eWallet. Merchant Reference No. 7RWFE66ZS1QX8",
        amount: 22.50,
        transactionType: 1,
        transactionCategory: 3),
    NotificationEventEntity(
        title: "Payment To: A&W SERI ISKANDAR",
        text:
            "A&W SERI ISKANDAR: RM15.00 has been deducted from you TNG eWallet. Merchant Reference No. 07SEfbsR3NPP",
        amount: 15.00,
        transactionType: 1,
        transactionCategory: 3),
    NotificationEventEntity(
        title: "Payment To: TGV Cinemas Sdn Bhd ",
        text:
            "TGV Cinemas Sdn Bhd: RM18.00 has been deducted from you TNG eWallet. Merchant Reference No. 07GFDV23SX2NSA",
        amount: 18.00,
        transactionType: 1,
        transactionCategory: 1),
    NotificationEventEntity(
        title: "Payment To: Keretapi Tanah Melayu Berhad (KTMB)",
        text:
            "Keretapi Tanah Melayu Berhad (KTMB): RM58.00 has been deducted from you TNG eWallet. Merchant Reference No. 07XEGV78CV3BNG",
        amount: 58.00,
        transactionType: 1,
        transactionCategory: 0),
    NotificationEventEntity(
        title: "Ka-ching! Incoming money",
        text: "RM 25.00 received from MICHAEL TAN for Fund Transfer.",
        amount: 25.00,
        transactionType: 2,
        transactionCategory: 4),
    NotificationEventEntity(
        title: "Payment To: Telekom Malaysia Berhad  (TM)",
        text: "RM 25.00 received from MICHAEL TAN for Fund Transfer.",
        amount: 25.00,
        transactionType: 2,
        transactionCategory: 4),
    NotificationEventEntity(
        title: "Ka-ching! Incoming money",
        text:
            "Telekom Malaysia Berhad (TM): RM200.00 has been deducted from you TNG eWallet. Merchant Reference No. 07JHGV34CV6LOP",
        amount: 200.00,
        transactionType: 1,
        transactionCategory: 2),
    NotificationEventEntity(
        title: "Payment To: redBus",
        text:
            "redBus: RM25.00 has been deducted from you TNG eWallet. Merchant Reference No. 07RGHJ89CV3JUZR",
        amount: 25.00,
        transactionType: 1,
        transactionCategory: 0),
    NotificationEventEntity(
        title: "Maybank2u: Funds Received",
        text:
            "You've just received RM34.00 in your account ending ***7654. REF: 20240801CIGGMYKL020ORM01052599",
        amount: 34.00,
        transactionType: 2,
        transactionCategory: 4),
    NotificationEventEntity(
        title: "Payment To: 7eleven Greentown Ipoh PRK",
        text:
            "eleven Greentown Ipoh PRK: RM10.00 has been deducted from you TNG eWallet. Merchant Reference No. 07CDF67FD4YTT",
        amount: 10.00,
        transactionType: 1,
        transactionCategory: 3),
  ];
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

    if (FirebaseAuth.instance.currentUser!.uid.isEmpty) {
      debugPrint("User is not authenticated. Cannot save event.");
      return;
    }
    try {
      DocumentReference userDocRef = firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      CollectionReference eventsCollection = userDocRef.collection('events');

      String docRef = eventsCollection.doc().id;
      entity.docId = docRef;

      await eventsCollection.doc(docRef).set(entity.toMap());
      debugPrint('Event saved to Firebase: ${entity.toMap()}');
      notifyListeners();
    } catch (error) {
      debugPrint('Error saving event to Firebase: $error');
    }
  }

  Future<void> removeEventFromFirebase(NotificationEventEntity entity) async {
    // if (currentUserUid == null) {
    //   debugPrint("User is not authenticated. Cannot remove event.");
    //   return;
    // }
    try {
      DocumentReference userDocRef = firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      CollectionReference eventsCollection = userDocRef.collection('events');
      eventsCollection.doc(entity.docId).delete();

      // QuerySnapshot querySnapshot = await eventsCollection
      //     .where('timestamp', isEqualTo: entity.timestamp)
      //     .get();

      // for (QueryDocumentSnapshot document in querySnapshot.docs) {
      //   await document.reference.delete();
      //   debugPrint('Event removed from Firebase: ${entity.toMap()}');
      // }
      notifyListeners();
    } catch (error) {
      debugPrint('Error removing event from Firebase: $error');
    }
  }

  Future<void> saveEventsToFirebaseWithDelay(
      List<NotificationEventEntity> events) async {
    for (var event in events) {
      await saveEventToFirebase(event);
      await Future.delayed(Duration(seconds: 1));
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
