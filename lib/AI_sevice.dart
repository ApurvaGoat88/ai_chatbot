import 'dart:convert';

import 'package:http/http.dart' as http;

import 'secret.dart';

class OpenAIService {
  final List<Map<String, String>> mess = [];
  Future<String> isAPIPromt(String promt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer  $OPENAIKEY"
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          'messages': [
            {
              'role': 'user',
              'content':
                  'Does this message want to generate a image , an Ai picture ,art or anything  similar ? $promt . simply answer in yes or no ',
            }
          ]
        }),
      );
      print(res.body);
      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch (content) {
          case 'yes':
          case 'Yes':
          case 'Yes.':
          case 'Yes':
            final res = await DALLE(promt);
            return res;
          default:
            final res = await ChatGPTAPI(promt);
            return res;
        }
      }
    } catch (e) {
      return e.toString();
    }
    return 'error';
  }

  Future<String> ChatGPTAPI(String promt) async {
    mess.add({
      'role': 'user',
      'content': promt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer  $OPENAIKEY"
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          'messages': mess,
        }),
      );

      if (res.statusCode == 200) {
        String content =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        mess.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'error';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> DALLE(String promt) async {
    mess.add({
      'role': 'user',
      'content': promt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $OPENAIKEY',
        },
        body: jsonEncode({
          'prompt': promt,
          'n': 1,
        }),
      );
      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        mess.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
