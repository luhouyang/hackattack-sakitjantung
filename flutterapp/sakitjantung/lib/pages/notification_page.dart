import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/usecase/noti_listener_usecase.dart';

import '../usecase/navigation_usecase.dart';
import '../widgets/notification_card.dart';

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
