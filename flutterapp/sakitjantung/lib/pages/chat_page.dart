import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Page")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message["sender"] == "user"
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message["sender"] == "user"
                            ? Colors.blueAccent
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message!["message"]!,
                        style: TextStyle(
                          color: message["sender"] == "user"
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type your message...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
