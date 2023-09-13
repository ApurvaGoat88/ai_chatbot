import 'package:ai_chatbot/secret.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late OpenAI openAI;
  final TextEditingController _controller = TextEditingController();

  final List<Chat> _mess = [];
  @override
  void initState() {
    openAI = OpenAI.instance.build(token: chatkey);
    super.initState();
  }

  void _send() async {
    var text = _controller.text;
    if (text.trim().isEmpty) {
      return;
    }
    _controller.clear();

    setState(() {
      _mess.add(Chat(_controller.text, true));
    });
    var res = await openAI.onCompletion(
        request: CompleteText(prompt: text, model: TextBabbage001Model()));

    if (res!.choices.isNotEmpty && res != null) {
      var ans = res.choices.last.text;
      setState(() {
        _mess.add(Chat(ans, false));
        print(res.choices.last.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ChatBot'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
                child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index) {
                var chat = _mess[index];
                return Align(
                  alignment:
                      chat.user ? Alignment.centerRight : Alignment.centerLeft,
                  child: Chip(
                      backgroundColor: chat.user
                          ? Colors.lightGreen.shade200
                          : Colors.blueGrey.shade100,
                      label: Text(
                        chat.text,
                        style: TextStyle(color: Colors.black),
                      )),
                );
              },
              itemCount: _mess.length,
            )),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: 'Send A Message'),
                    )),
                    IconButton(onPressed: _send, icon: Icon(Icons.send)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
    ;
  }
}

class Chat {
  String text;
  bool user;
  Chat(this.text, this.user);
}
