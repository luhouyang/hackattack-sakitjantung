import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/services/firebase_services.dart';
import 'package:sakitjantung/usecase/noti_listener_usecase.dart';

import '../entities/noti_entity.dart';
import '../usecase/navigation_usecase.dart';

class NotificationCard extends StatelessWidget {
  final String? title;
  final String? text;
  final String time;
  final int index;
  final NotificationEventEntity event;
  const NotificationCard(
      {super.key,
      required this.title,
      required this.text,
      required this.time,
      required this.index,
      required this.event});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotiListenerUseCase>(
      builder: (context, eventsUseCase, value) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 6, 0, 4),
          child: Slidable(
            direction: Axis.horizontal,
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  borderRadius: BorderRadius.circular(10),
                  onPressed: (_) async {
                    await FirebaseService().removeEventFromFirebase(event);
                    await eventsUseCase.removeEvent(
                        eventsUseCase.convertToEvent(event), index);
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Remove',
                )
              ],
            ),
            child: Consumer<NavigationUseCase>(
              builder: (context, nav, child) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: (nav.dropDownValue == 1) ? 1 : 0,
                        color: (nav.dropDownValue == 1)
                            ? Colors.black
                            : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          spreadRadius: 1,
                          color: Colors.black.withOpacity(0.2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title ?? "<<no title>>",
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        text ?? "<<no text>>",
                        style: const TextStyle(fontSize: 13),
                        textAlign: TextAlign.justify,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
