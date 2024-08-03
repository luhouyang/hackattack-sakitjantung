import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/entities/noti_entity.dart';
import 'package:sakitjantung/services/firebase_services.dart';
import 'package:sakitjantung/usecase/noti_listener_usecase.dart';

import '../usecase/navigation_usecase.dart';
import '../widgets/notification_card.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Box? box;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      NotiListenerUseCase eventsUseCase =
          Provider.of<NotiListenerUseCase>(context, listen: false);
      await eventsUseCase.initPlatformState();
      box = await Hive.openBox("encryptionkey");
      eventsUseCase.initializeEventList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<NotiListenerUseCase, FirebaseService, NavigationUseCase>(
      builder: (context, e, f, n, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                TextButton(
                  onPressed: () async {
                    debugPrint("Starting.....");
                    await f.saveEventsToFirebaseWithDelay(f.dummyData);
                    debugPrint("Done hehehaha");
                  },
                  child: Text("Hehehaha"),
                ),
                // TextButton(
                //     onPressed: () async {
                //       int res1 = await classifyData(
                //           "Algorithm & Data Structure: Shashi Baka (OOP Lecturer) | Graphs.pptx");
                //       int res2 = await classifyData(
                //           "Ka-ching! Incoming money | Transaction to Hans, RM 10 with Touch n go");
                //       int res3 = await classifyData(
                //           "DuitNow Payment | You have paid RM6.00 to island one cafe and bakery.");
                //     },
                //     child: const Text("SEND")),

                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('events')
                      .orderBy('createAt')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          reverse: true,
                          itemBuilder: (BuildContext context, int idx) {
                            // final entry = e.eventsEntities[idx];
                            NotificationEventEntity entry =
                                NotificationEventEntity.fromMap(
                                    snapshot.data!.docs[idx].data());

                            try {
                              // get key and iv
                              enc.Key? key;
                              enc.IV? iv;

                              // if (box!.values.isEmpty) {
                              //   key = enc.Key.fromLength(32);
                              //   iv = enc.IV.fromLength(8);
                              //   box!.put('salsa20', key.base64);
                              //   box!.put('iv', iv.base64);
                              //   debugPrint("Generating Key");
                              // } else {
                              //   key = enc.Key.fromBase64(
                              //       box!.get('salsa20')!);
                              //   iv = enc.IV.fromBase64(box!.get('iv')!);
                              // }
                              List<String> keys = box!.get('salsa20')!;
                              List<String> ivs = box!.get('iv')!;

                              key = enc.Key.fromBase64(keys[idx]);
                              iv = enc.IV.fromBase64(ivs[idx]);

                              final encrypter = enc.Encrypter(enc.Salsa20(key));
                              final decrypted = encrypter.decrypt(
                                  enc.Encrypted(base64Decode(entry.text)),
                                  iv: iv);
                              debugPrint(decrypted);

                              entry.text = decrypted;
                            } catch (e) {
                              debugPrint("Error at notification page: $e");
                            }

                            return NotificationCard(
                              title: entry.title,
                              text: entry.text,
                              time: entry.createAt.toString().substring(0, 19),
                              index: idx,
                              event: entry,
                            );
                          });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
