import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_chat_app/model/message.dart';
import 'package:firebase_chat_app/model/user.dart';
import 'package:firebase_chat_app/provider/audio_controller.dart';
import 'package:firebase_chat_app/service/firebase_firestore_service.dart';
import 'package:firebase_chat_app/service/media_service.dart';
import 'package:firebase_chat_app/service/notification_service.dart';
import 'package:firebase_chat_app/view/widgets/empty_widget.dart';
import 'package:firebase_chat_app/view/widgets/message_audio.dart';
import 'package:firebase_chat_app/view/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record_mp3/record_mp3.dart';
import '../../provider/firebase_provider.dart';
import '../widgets/chat_messages.dart';
import '../widgets/chat_text_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.userId});

  final String userId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    Provider.of<FirebaseProvider>(context, listen: false)
      ..getUserById(widget.userId)
      ..getMessages(widget.userId);
    notificationsService
        .getReceiverToken(widget.userId);
    super.initState();
  }
    final controller = TextEditingController();
  final notificationsService = NotificationsService();
  Uint8List? file;
  late File audioFile;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  AudioController audioController = Get.put(AudioController());
  AudioPlayer audioPlayer = AudioPlayer();
  String audioURL = "";
  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
  late String recordFilePath;

  int i=0;
  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath =
        "${storageDirectory.path}/record${DateTime.now().microsecondsSinceEpoch}.acc";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return "$sdPath/test_${i++}.mp3";
  }
  void startRecord() async {
    bool hasPermission = await checkPermission();
    print("Recordinnnnnnnggggg about to start");
    if (hasPermission) {
      recordFilePath = await getFilePath();
      RecordMp3.instance.start(recordFilePath, (type) {
        setState(() {});
      });
    } else {}
    setState(() {});
  }

  void stopRecord() async {
    bool stop = RecordMp3.instance.stop();
    print("@@@@@@@@@@ stop Record");
    audioController.end.value = DateTime.now();
    audioController.calcDuration();
    print("Stooopppppp Recordinnnnnnnggggg");
    var ap = AudioPlayer();
    await ap.play(AssetSource("Notification.mp3"));
    ap.onPlayerComplete.listen((a) {});
    if (stop) {
      audioController.isRecording.value = false;
      audioController.isSending.value = true;
      await _sendAudio();
    }
  }

  Widget ChatMessages(){
    return Consumer<FirebaseProvider>(
        builder: (context, value, child) => value
                .messages.isEmpty
            ? const Expanded(
                child: EmptyWidget(
                    icon: Icons.waving_hand,
                    text: 'Say Hello!'),
              )
            : Expanded(
                child: ListView.builder(
                  controller: Provider.of<FirebaseProvider>(
                          context,
                          listen: false)
                      .scrollController,
                  itemCount: value.messages.length,
                  itemBuilder: (context, index) {
                    final isAudio = value.messages[index].messageType ==MessageType.audio;
                    final isTextMessage =
                        value.messages[index].messageType ==
                            MessageType.text;
                    final isMe = widget.userId !=
                        value.messages[index].senderId;

                    return isAudio?
                      MessageAudio(message: value.messages[index], isMe: isMe, index: index, duration: value.messages[index].duration,)
                      :isTextMessage  ? MessageBubble(
                            isMe: isMe,
                            message: value.messages[index],
                            isImage: false,
                          )
                        : MessageBubble(
                            isMe: isMe,
                            message: value.messages[index],
                            isImage: true,
                          );
                  },
                ),
              ),
      );
  }

  Widget ChatTextField(){
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.25),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        //height: 50,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
              prefixIcon: Container(
                width: 80,
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      child: Icon(Icons.photo, color: Colors.green),
                      onTap: _sendImage,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      child: Icon(Icons.mic, color: Colors.green),
                      onLongPress: () async {
                        var audioPlayer = AudioPlayer();
                        await audioPlayer.play(AssetSource("Notification.mp3"));
                        audioPlayer.onPlayerComplete.listen((a) {
                          audioController.start.value = DateTime.now();
                          startRecord();
                          audioController.isRecording.value = true;
                        });
                      },
                      onLongPressEnd: (details) {
                        stopRecord();
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              suffixIcon: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  child: Icon(Icons.send, color: Colors.green),
                  onTap: () {
                    _sendText(context);
                    controller.text = "";
                    }
                  
                ),
              ),
              hintText: audioController.isRecording.value
                  ? "Recording audio..."
                  : "Your message...",
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              hintStyle: TextStyle(color: Color(0xff8A8A8A), fontSize: 15),
              border: InputBorder.none),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ChatMessages(),
            ChatTextField(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() => AppBar(
    elevation: 0,
    foregroundColor: Colors.black,
    backgroundColor: Colors.transparent,
    title: Consumer<FirebaseProvider>(
      builder: (context, value, child) =>
          value.user != null
              ? Row(
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          NetworkImage(value.user!.image ?? "data:image/jpeg;base64,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"),
                      radius: 20,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      children: [
                        Text(
                          value.user!.name,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          value.user!.isOnline
                              ? 'Online'
                              : 'Offline',
                          style: TextStyle(
                            color: value.user!.isOnline
                                ? Colors.green
                                : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : const SizedBox(),
    ),
  );

  Future<void> _sendText(BuildContext context) async {
    if (controller.text.isNotEmpty) {
      await FirebaseFirestoreService.addTextMessage(
        receiverId: widget.userId,
        content: controller.text,
      );
      await notificationsService.sendNotification(
        body: controller.text,
        senderId: FirebaseAuth.instance.currentUser!.uid,
      );
      controller.clear();
      FocusScope.of(context).unfocus();
    }
    FocusScope.of(context).unfocus();
  }

  Future<void> _sendImage() async {
    final pickedImage = await MediaService.pickImage();
    setState(() => file = pickedImage);
    if (file != null) {
      await FirebaseFirestoreService.addImageMessage(
        receiverId: widget.userId,
        file: file!,
      );
      await notificationsService.sendNotification(
        body: 'image........',
        senderId: FirebaseAuth.instance.currentUser!.uid,
      );
    }
  }

  Future<void> _sendAudio() async {
    setState(() => audioFile = File(recordFilePath));
    if (audioFile != null) {
      await FirebaseFirestoreService.addAudioMessage(
        receiverId: widget.userId,
        file: audioFile!,
        duration: audioController.total,
      );
      await notificationsService.sendNotification(
        body: 'Auddiooo........',
        senderId: FirebaseAuth.instance.currentUser!.uid,
      );
    }
  }

}
