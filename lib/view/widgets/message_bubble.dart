import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_chat_app/provider/audio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../constants.dart';
import '../../model/message.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({
    super.key,
    required this.isMe,
    required this.isImage,
    required this.message,
  });

  final bool isMe;
  final bool isImage;
  final Message message;

  AudioController audioController = Get.put(AudioController());
  AudioPlayer audioPlayer = AudioPlayer();

  // Widget audioWidget(){
  //   return Row(
  //       children: [
  //         GestureDetector(
  //           onTap: () {
  //             audioController.onPressedPlayButton(index, message);
  //             // changeProg(duration: duration);
  //           },
  //           onSecondaryTap: () {
  //             audioPlayer.stop();
  //             //   audioController.completedPercentage.value = 0.0;
  //           },
  //           child: Obx(
  //             () => (audioController.isRecordPlaying &&
  //                     audioController.currentId == index)
  //                 ? Icon(
  //                     Icons.cancel,
  //                     color: isMe ? Colors.white : mainColor,
  //                   )
  //                 : Icon(
  //                     Icons.play_arrow,
  //                     color: isMe ? Colors.white : mainColor,
  //                   ),
  //           ),
  //         ),
  //         Obx(
  //           () => Expanded(
  //             child: Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 0),
  //               child: Stack(
  //                 clipBehavior: Clip.none,
  //                 alignment: Alignment.center,
  //                 children: [
  //                   // Text(audioController.completedPercentage.value.toString(),style: TextStyle(color: Colors.white),),
  //                   LinearProgressIndicator(
  //                     minHeight: 5,
  //                     backgroundColor: Colors.grey,
  //                     valueColor: AlwaysStoppedAnimation<Color>(
  //                       isMe ? Colors.white : mainColor,
  //                     ),
  //                     value: (audioController.isRecordPlaying &&
  //                             audioController.currentId == index)
  //                         ? audioController.completedPercentage.value
  //                         : audioController.totalDuration.value.toDouble(),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           width: 10,
  //         ),
  //         Text(
  //           duration,
  //           style: TextStyle(
  //               fontSize: 12, color: isMe ? Colors.white : mainColor),
  //         ),
  //       ],
  //     );
  // }



  @override
  Widget build(BuildContext context) => Align(
        alignment:
            isMe ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            color: !isMe ? mainColor : const Color.fromARGB(255, 36, 120, 38),
            borderRadius: !isMe
                ? const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
          ),
          margin: const EdgeInsets.only(
              top: 10, right: 10, left: 10),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              isImage
                  ? Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(15),
                        image: DecorationImage(
                          image:
                              NetworkImage(message.content),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  : Text(message.content,
                      style: const TextStyle(
                          color: Colors.white)),
              const SizedBox(height: 5),
              Text(
                timeago.format(message.sentTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
}
