import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_chat_app/model/message.dart';
import 'package:firebase_chat_app/provider/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
class MessageAudio extends StatelessWidget {
  final Message message;
  final bool isMe;
  final int index;
  final String duration;


  MessageAudio({required this.message, required this.isMe, required this.index, required this.duration});

  AudioController audioController = Get.put(AudioController());
  AudioPlayer audioPlayer = AudioPlayer();

  

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.green : Colors.green.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              audioController.onPressedPlayButton(index, message.content);
              // changeProg(duration: duration);
            },
            onSecondaryTap: () {
              audioPlayer.stop();
              //   audioController.completedPercentage.value = 0.0;
            },
            child: Obx(
              () => (audioController.isRecordPlaying &&
                      audioController.currentId == index)
                  ? Icon(
                      Icons.cancel,
                      color: isMe ? Colors.white : Colors.green,
                    )
                  : Icon(
                      Icons.play_arrow,
                      color: isMe ? Colors.white : Colors.green,
                    ),
            ),
          ),
          Obx(
            () => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Text(audioController.completedPercentage.value.toString(),style: TextStyle(color: Colors.white),),
                    LinearProgressIndicator(
                      minHeight: 5,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isMe ? Colors.white : Colors.green,
                      ),
                      value: (audioController.isRecordPlaying &&
                              audioController.currentId == index)
                          ? audioController.completedPercentage.value
                          : audioController.totalDuration.value.toDouble(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            duration,
            style: TextStyle(
                fontSize: 12, color: isMe ? Colors.white : Colors.green),
          ),
        ],
      ),
    );
  }
}
