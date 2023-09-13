import 'package:ai_chatbot/chatscrren/chatscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'spin.dart';
import 'feature.dart';
import 'AI_sevice.dart';
import 'package:animate_gradient/animate_gradient.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  SpeechToText _speechToText = SpeechToText();
  final tts = FlutterTts();
  String lastWords = '';
  bool cont_vis = false;
  bool vis = true;
  final OpenAIService _aiService = OpenAIService();
  String? gen_word = null;
  String? img_url = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
    initTTS();
  }

  Future<void> initTTS() async {
    await tts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> _initSpeech() async {
    await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await tts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    _speechToText.stop();
    tts.stop();
  }

  var font_color = Colors.blue.shade700;
  var border_color = Colors.grey.shade300;
  @override
  Widget build(BuildContext context) {
    return AnimateGradient(
      primaryColors: [
        Colors.black,
        Colors.blue.shade700,
        // const Color(0XFFE0A96D),
        // const Color(0xFFDDC3A5),
      ],
      secondaryColors: [
        Colors.blue.shade700, Colors.black,
        // const Color(0xFFB85042),
        // const Color(0xFFA7BEAE),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          title: const Text('AI Voice Assistant'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatScreen()));
                },
                icon: Icon(Icons.message)),
            Padding(padding: EdgeInsets.only(right: 7))
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SpinItem(),
                const SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: cont_vis,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      lastWords,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: gen_word == null ? 22 : 20,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20))
                                .copyWith(topRight: Radius.zero)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    gen_word == null ? 'Hey !,Assign me a New Task' : gen_word!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: gen_word == null ? 22 : 20,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20))
                          .copyWith(topLeft: Radius.zero)),
                ),
                SizedBox(
                  height: 20,
                ),

                SizedBox(
                  height: 20,
                ),
                //if (img_url != null) Image.network(img_url!),
                Visibility(
                  visible: vis,
                  child: Column(
                    children: [
                      Features(
                        color: Colors.blue.shade200,
                        text: 'ChatGPT',
                        Des:
                            'Navigate to world of AI, Through ChtGPT,an Open AI  ',
                      ),
                      // Features(
                      //     color: Colors.purple.shade100,
                      //     text: 'DALL-E',
                      //     Des:
                      //         'Get inspired ans stay creative with your personal assistant by DALL-E'),
                      Features(
                          color: Color.fromARGB(255, 245, 133, 235),
                          text: 'Smart Voice Assistant',
                          Des:
                              'Get the best of worlds with voice assistant powered by DALL-E  and ChatGPT  ')
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (await _speechToText.hasPermission &&
                _speechToText.isNotListening) {
              await _startListening();
            } else if (_speechToText.isListening) {
              final response = await _aiService.isAPIPromt(lastWords);
              if (response.contains('https')) {
                img_url = response;
                gen_word = null;
                setState(() {});
              } else {
                img_url = null;
                gen_word = response;
                setState(() {
                  vis = false;
                  cont_vis = true;
                });
                await systemSpeak(response);
              }
              print(response);

              await _stopListening();
              print(lastWords);
            } else {
              _initSpeech();
            }
          },
          child: Icon(Icons.mic_none_rounded),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
