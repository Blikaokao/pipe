import 'dart:async';
import 'dart:convert';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:todo_list/config/api_service.dart';
import 'package:todo_list/json/event_bean.dart';
import 'package:todo_list/json/task_bean.dart';
import 'package:todo_list/model/all_model.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:todo_list/widgets/speech_result.dart';


const theSource = AudioSource.microphone;

class LCPainter extends CustomPainter {
  final double amplitude;
  final int number;
  LCPainter({this.amplitude = 100.0, this.number = 20});
  @override
  void paint(Canvas canvas, Size size) {
    var centerY = 0.0;
    var width = ScreenUtil.defaultSize.width / number;

    for (var a = 0; a < 4; a++) {
      var path = Path();
      path.moveTo(0.0, centerY);
      var i = 0;
      while (i < number) {
        path.cubicTo(width * i, centerY, width * (i + 1),
            centerY + amplitude - a * (30), width * (i + 2), centerY);
        path.cubicTo(width * (i + 2), centerY, width * (i + 3),
            centerY - amplitude + a * (30), width * (i + 4), centerY);
        i = i + 4;
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = a == 0 ? Colors.blueAccent : Colors.blueGrey.withAlpha(50)
            ..strokeWidth = a == 0 ? 3.0 : 2.0
            ..maskFilter = MaskFilter.blur(
              BlurStyle.solid,
              5,
            )
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
class SpeechInput extends StatefulWidget {
  @override
  _SpeechInputState createState() => _SpeechInputState();
}

class _SpeechInputState extends State<SpeechInput> {

  String _text = "";
  Codec _codec = Codec.pcm16;
  String _mPath = "";
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  StreamSubscription _recorderSubscription;
  EditTaskPageModel model = EditTaskPageModel();

  bool _recording = false;
  double _dbLevel = 0;
  File file;
  CancelToken cancelToken = CancelToken();

  // ///测试！！！！
  // AudioPlayer audioPlayer = new AudioPlayer();

  @override
  void initState() {
    openTheRecorder();
    super.initState();
  }

  @override
  void dispose() {
    _mRecorder.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder.openRecorder();
    _mRecorder.setSubscriptionDuration(Duration(milliseconds: 30));
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
      AVAudioSessionCategoryOptions.allowBluetooth |
      AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
      AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    _mPath = (await getApplicationDocumentsDirectory()).path + '/temp.pcm';

  }

  // ----------------------  Here is the code for recording and playback -------

  void record() async {
    file = File(_mPath);

    await _mRecorder.startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: theSource,
    );


    _recorderSubscription = _mRecorder.onProgress.listen((e) {
      if (e != null && e.duration != null) {
        setState(() {
          _dbLevel = e.decibels;
          _recording = true;
        });
      }
    });
  }

  void stopRecorder() async {
    await _mRecorder.stopRecorder().then((value) {
      setState(() {
        _dbLevel = 0;
      });
    });
    // await audioPlayer.play(_mPath);
    _cancelRecorderSubscriptions();
    await _getText();
    file.deleteSync(); //删除文件

    //处理逻辑
    showModalBottomSheet(
        backgroundColor:Colors.transparent,
        barrierColor:Colors.transparent,
        context: context,
        builder: (_)=>SpeechResult(_text,model)
    ).then((v){
      Navigator.of(context).pop();
    });
  }

  /// 取消录音监听
  void _cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
  }


  _getText() async {
    List<int> fileBytes = await file.readAsBytesSync();
    String speech = base64Encode(fileBytes);


    ApiService.instance.postByVoice(
      success: (EventBean bean) {
        Fluttertoast.showToast(
            msg: "提取完成",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black38,
            textColor: Colors.white,
            fontSize: 16.0
        );
        List<Event> events = bean.events;
        model.eventsNum = events.length;
        model.flag = List.generate(model.eventsNum, (index) => true);
        model.tasks = List.generate(model.eventsNum, (index) => TaskBean());
        if(events.length>0){
          model.startDates.clear();
          model.deadLines.clear();
          model.currentTaskNames.clear();
        }else{
          model.eventsNum = 1;
        }
        for(int i=0;i<events.length;i++){
          Event event = events[i];
          event.startDate!=""? model.startDates.add(DateTime.parse(event.startDate)):model.startDates.add(null);
          event.deadLine!=""? model.deadLines.add(DateTime.parse(event.deadLine)):model.deadLines.add(null);
          event.taskName!=""? model.currentTaskNames.add(event.taskName):model.currentTaskNames.add("");
        }

        model.refresh();

        // _text = res["result"];
      },
      failed: (EventBean bean) {
        // Navigator.of(_model.context).pop();
        // if (bean.description.contains("任务不存在")) {
        //   _deleteDataBaseTask(taskBean);
        // } else {
        //   _showTextDialog(bean.description);
        // }
      },
      error: (msg) {
        // Navigator.of(_model.context).pop();
        // _showTextDialog(msg);
      },
      params: {
        "len": await file.length(),
        "speech": speech,
      },
      token: cancelToken,
    );

  }


  @override
  Widget build(BuildContext context) {

    return Container(
      height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
          SizedBox(height:30),
          Text(_recording ? "松手结束" : "按住录音",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 30,
              )),
          Container(
              width: double.maxFinite,
              height: 80,
              alignment: Alignment.center,
              child: GestureDetector(
                child: Image.asset("images/microphone.png"),
                onLongPress: () {
                  setState(() {
                    _recording = true;
                  });
                  record();
                },
                onLongPressUp: () {
                  _recording = false;
                  stopRecorder();
                },
              )),
          SizedBox(height:60),
          CustomPaint(
              size: Size(double.maxFinite, 100),
              painter: LCPainter(
                  amplitude: _dbLevel / 2, number: 30 - _dbLevel ~/ 20)),
          // LCPainter(amplitude: _dbLevel / 2, number: 30 - _dbLevel ~/ 20)),
        ]));
  }
}

