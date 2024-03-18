import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static Future<String> uploadImage(
          Uint8List file, String storagePath) async =>
      await FirebaseStorage.instance
          .ref()
          .child(storagePath)
          .putData(file)
          .then((task) => task.ref.getDownloadURL());

  static Future<String> uploadAudio(
          var audioFile, String fileName) async =>
      await FirebaseStorage.instance
          .ref()
          .child(fileName)
          .putFile(audioFile)
          .then((task) => task.ref.getDownloadURL());

}
