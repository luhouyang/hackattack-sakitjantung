import 'package:dash_chat_2/dash_chat_2.dart' as dash;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:sakitjantung/llm/dataset.dart';

import '../llm/model.dart';

class ChatUseCase extends ChangeNotifier {
  LLM llm = LLM();
  Dataset dataset = Dataset();
  int documentSelected = 0;
  dash.ChatUser user = dash.ChatUser(
    id: '1',
    firstName: FirebaseAuth.instance.currentUser!.email,
  );

  dash.ChatUser bot = dash.ChatUser(
    id: '0',
    firstName: 'ChatBot',
  );

  List<dash.ChatMessage> messages = <dash.ChatMessage>[];
  List<dash.ChatUser> typingUsers = <dash.ChatUser>[];

  void addMessage(dash.ChatMessage m, List<Document> docs) async {
    messages.insert(0, m);

    //get response
    typingUsers.add(bot);
    notifyListeners();
    String res = await llm.rag(docs, m.text);
    messages.insert(
        0, dash.ChatMessage(user: bot, createdAt: DateTime.now(), text: res));

    typingUsers.remove(bot);
    notifyListeners();
  }

  void changeSelectedDocument(int index) {
    documentSelected = index;
    notifyListeners();
  }
}
