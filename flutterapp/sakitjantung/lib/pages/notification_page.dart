import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/usecase/noti_listener_usecase.dart';

import '../usecase/navigation_usecase.dart';
import '../widgets/notification_card.dart';

import 'package:http/http.dart' as http; //TODO: added stuff

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      NotiListenerUseCase eventsUseCase =
          Provider.of<NotiListenerUseCase>(context, listen: false);
      await eventsUseCase.initPlatformState();
      eventsUseCase.startListening(); // Start listening for notifications
    });
  }

  //TODO: added stuff
  Future<int> classifyData(String message) async {
    Map<String, int> responseClasses = {
      "NOT TRANSACTION": 0,
      "MONEY OUT": 1,
      "MONEY IN": 2
    };

    List<String> resList = [];

    final url = Uri.parse('http://47.250.87.162:9000/api/classify');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'data': message}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      resList.add(data['prediction']);
      // print('Prediction: ${data['prediction']}');
    } else {
      resList.add("ERROR");
      // print('Failed to load data');
    }

    if (resList[0] == "ERROR") {
      debugPrint("Something went wong");
      return -1;
    } else {
      if (responseClasses[resList[0]] == 0) {
        debugPrint("NOT A TRANSACTION");
        return 0;
      } else if (responseClasses[resList[0]] == 1) {
        debugPrint("MONEY OUT");
        return 1;
      } else if (responseClasses[resList[0]] == 2) {
        debugPrint("MONEY IN");
        return 2;
      }
    }

    debugPrint("Something went wong");
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotiListenerUseCase, NavigationUseCase>(
      builder: (context, e, n, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                //TODO: added stuff
                TextButton(
                    onPressed: () async {
                      int res1 = await classifyData(
                          "Algorithm & Data Structure: Shashi Baka (OOP Lecturer) | Graphs.pptx");
                      int res2 = await classifyData(
                          "Ka-ching! Incoming money | aelbgla rg gg hehe boi Transaction to Hans, RM 10 with Touch n go");
                      int res3 = await classifyData(
                          "DuitNow Payment | You have paid RM6.00 to island one cafe and bakery.");
                    },
                    child: Text("SEND")),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Notification List",
                      style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                (n.dropDownValue == 0)
                    ? FutureBuilder(
                        future: e.loadEvents(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text("Error: ${snapshot.error}");
                          } else {
                            return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: e.eventsEntities.length,
                                reverse: true,
                                itemBuilder: (BuildContext context, int idx) {
                                  final entry = e.eventsEntities[idx];
                                  return NotificationCard(
                                    title: entry.title,
                                    text: entry.text,
                                    time: entry.createAt
                                        .toString()
                                        .substring(0, 19),
                                    event: entry,
                                  );
                                });
                          }
                        },
                      )
                    : const Center(child: Text("Notification List is Empty")),
              ],
            ),
          ),
        );
      },
    );
  }
}
