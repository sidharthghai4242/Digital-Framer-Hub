import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../helper/Constants.dart';
import '../helper/localization/language_constants.dart';
import '../helper/theme_class.dart';
import '../models/ExtraModel.dart';
import '../models/FarmerModel.dart';
import '../models/FeedbackModel.dart';

class FeedBackPage extends StatefulWidget {
  FarmerModel? farmerModel;
  ExtraModel? extraModel = ExtraModel();
  String? uid;

  FeedBackPage(this.uid, this.extraModel, {super.key});

  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  bool isRecording = false;
  bool isPlaying = false;
  String? _audioFilePath;
  bool _isRecordingInitialized = false;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _initializePlayer();
  }

  void _initializeRecorder() async {
    try {
      await _recorder.openRecorder();
      setState(() {
        _isRecordingInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize recorder: $e')),
      );
    }
  }

  void _initializePlayer() async {
    try {
      await _player.openPlayer();
      setState(() {
        _isPlayerInitialized = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize player: $e')),
      );
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    super.dispose();
  }

  void _startRecording() async {
    if (!_isRecordingInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recorder is not initialized')),
      );
      return;
    }

    var status = await Permission.microphone.request();
    if (status.isGranted) {
      try {
        Directory appDir = await getApplicationDocumentsDirectory();
        String filePath = '${appDir.path}/feedback_${DateTime.now().millisecondsSinceEpoch}.aac';
        await _recorder.startRecorder(toFile: filePath);
        setState(() {
          isRecording = true;
          _audioFilePath = filePath;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Microphone permission is required to record audio')),
      );
    }
  }

  void _stopRecording() async {
    if (!_isRecordingInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recorder is not initialized')),
      );
      return;
    }

    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
      setState(() {
        isRecording = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No recording to stop')),
      );
    }
  }

  void _playAudio() async {
    if (!_isPlayerInitialized || _audioFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Player is not initialized or no audio recorded')),
      );
      return;
    }

    if (!isPlaying) {
      try {
        await _player.startPlayer(
          fromURI: _audioFilePath!,
          codec: Codec.aacADTS,
          whenFinished: () {
            setState(() {
              isPlaying = false;
            });
          },
        );
        setState(() {
          isPlaying = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play audio: $e')),
        );
      }
    } else {
      await _player.stopPlayer();
      setState(() {
        isPlaying = false;
      });
    }
  }

  void _sendFeedback() async {
    if (_feedbackController.text.isNotEmpty || _audioFilePath != null) {
      Map<String, dynamic>? audioData;
      Map<String, dynamic>? textFeedbackData;

      if (_audioFilePath != null) {
        String? audioUrl = await _uploadAudio(_audioFilePath!);
        if (audioUrl != null) {
          audioData = {
            'url': audioUrl,
            'timestamp': DateTime.now(),
          };
        }
      }

      if (_feedbackController.text.isNotEmpty) {
        textFeedbackData = {
          'feedback': _feedbackController.text,
          'timestamp': DateTime.now(),
        };
      }

      DocumentReference feedbackDocRef = FirebaseFirestore.instance.collection(feedBackCollection).doc(widget.uid);

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(feedbackDocRef);

          if (!snapshot.exists) {
            // Create a new document if it doesn't exist
            FeedbackModel feedbackModel = FeedbackModel(
              farmerUid: widget.uid!,
              timestamp: DateTime.now(),
              feedback: textFeedbackData != null ? [textFeedbackData] : [],
              audioFeedback: audioData != null ? [audioData] : [],
            );

            transaction.set(feedbackDocRef, feedbackModel.toJson());
          } else {
            // Update the existing document
            List<dynamic> existingAudioFeedback = snapshot.get('audioFeedback') ?? [];
            if (audioData != null) {
              existingAudioFeedback.add(audioData);
            }

            List<dynamic> existingTextFeedback = snapshot.get('feedback') ?? [];
            if (textFeedbackData != null) {
              existingTextFeedback.add(textFeedbackData);
            }

            transaction.update(feedbackDocRef, {
              'feedback': existingTextFeedback,
              'timestamp': DateTime.now(),
              'audioFeedback': existingAudioFeedback,
            });
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Feedback sent successfully!')),
        );
        _feedbackController.clear();
        setState(() {
          _audioFilePath = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send feedback: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback cannot be empty')),
      );
    }
  }

  Future<String?> _uploadAudio(String filePath) async {
    File file = File(filePath);
    try {
      String fileName = 'feedback_audio/${widget.uid}_${DateTime.now().millisecondsSinceEpoch}.aac';
      UploadTask uploadTask = FirebaseStorage.instance.ref().child(fileName).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload audio: $e')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "${getTranslated(context, 'SendFeedback')}",
          style: TextStyle(
            color: ThemeClass.colorPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "${getTranslated(context, 'TimeisyourmostvaluableresourceWeareheretogetthisrightforyou')}",
              style: TextStyle(
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "${getTranslated(context, 'Enteryourfeedbackhere')}",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${getTranslated(context, 'Orrecordanaudio')}",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: isRecording ? _stopRecording : _startRecording,
                  child: CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 30,
                    child: Icon(
                      isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (_audioFilePath != null)
                  GestureDetector(
                    onTap: _playAudio,
                    child: CircleAvatar(
                      backgroundColor: Colors.green,
                      radius: 30,
                      child: Icon(
                        isPlaying ? Icons.stop : Icons.play_arrow,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
              ],
            ),
            if (_audioFilePath != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '${getTranslated(context, 'Audiorecorded')} ${_audioFilePath!.split('/').last}',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeClass.colorPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                "${getTranslated(context, 'SendFeedback')}",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
