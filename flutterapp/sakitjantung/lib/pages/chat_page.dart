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
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({"sender": "user", "message": _controller.text});
      });
      _controller.clear();
      // Call your AI API here to get a response
      _getAIResponse();
    }
  }

  Future<void> _getAIResponse() async {
    final userMessage = _messages.last["message"];
    // Replace this with your API call
    final responseMessage = await mockAIResponse(userMessage!);
    setState(() {
      _messages.add({"sender": "bot", "message": responseMessage});
    });
  }

  Future<String> mockAIResponse(String message) async {
    await Future.delayed(Duration(seconds: 1));
    return "AI response to \"$message\"";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatUseCase>(
      builder: (context, chatUseCase, child) {
        return Column(
          children: [
            const Text('Choose a topic'),
            const SizedBox(height: 10.0),
            Wrap(
              spacing: 5.0,
              children: List<Widget>.generate(
                chatUseCase.dataset.documentsByTopic.length,
                (int index) {
                  return ChoiceChip(
                    label: Text(chatUseCase.dataset.documentsByTopic.keys
                        .elementAt(index)),
                    selected: chatUseCase.documentSelected == index,
                    onSelected: (bool selected) {
                      chatUseCase.changeSelectedDocument(index);
                    },
                  );
                },
              ).toList(),
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
