import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sakitjantung/usecase/chat_usecase.dart';
import 'package:sakitjantung/utils/constants.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatUseCase>(
      builder: (context, chatUseCase, child) {
        return Column(
          children: [
            const Text('Choose a topic'),
            const SizedBox(height: 10.0),
            DropdownButton<int>(
              value: chatUseCase.documentSelected,
              onChanged: (int? newValue) {
                if (newValue != null) {
                  chatUseCase.changeSelectedDocument(newValue);
                }
              },
              items: List<DropdownMenuItem<int>>.generate(
                chatUseCase.dataset.documentsByTopic.length,
                (int index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(
                      chatUseCase.dataset.documentsByTopic.keys
                          .elementAt(index),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: DashChat(
                typingUsers: chatUseCase.typingUsers,
                messageOptions: MessageOptions(
                    showTime: true,
                    showOtherUsersName: true,
                    currentUserContainerColor: MyColours.primaryColour),
                currentUser: chatUseCase.user,
                onSend: (ChatMessage m) {
                  chatUseCase.addMessage(
                      m,
                      chatUseCase.dataset.documentsByTopic[chatUseCase
                          .dataset.documentsByTopic.keys
                          .elementAt(chatUseCase.documentSelected)]!);
                },
                messages: chatUseCase.messages,
              ),
            ),
          ],
        );
      },
    );
  }
}
