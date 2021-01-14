import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_recognition/speech_recognition.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SpeechRecognition _speechRecognition = SpeechRecognition();
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";
  PermissionStatus _status;

  @override
  void initState() {
    super.initState();
    _askPermission();
    _speechRecognition.setAvailabilityHandler(
          (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
          () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
          (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(
          () => setState(() => _isListening = false),
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
    );
  }

  void _updateStatus(PermissionStatus status){
    if(status != _status){
      setState(() {
        _status = status;
      });
    }
  }

  void _askPermission(){
    PermissionHandler().requestPermissions([PermissionGroup.microphone])
        .then(_onStatusRequested);
  }
  void _onStatusRequested(Map<PermissionGroup, PermissionStatus> statues){
    final status = statues[PermissionGroup.microphone];
    _updateStatus(status);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: speechButton(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(6.0),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 12.0,
            ),
            child: Text(
              resultText,
              style: TextStyle(fontSize: 24.0),
            ),
          ),
        ],
      ),
    );
  }

  speechButton() =>Container(
    height: 100,
    width: double.infinity,
    alignment: Alignment.center,
    child:   FloatingActionButton(
      child: Icon(Icons.mic),
      onPressed: () {
        print(_isAvailable.toString() + ' ' + _isListening.toString());
        if (_isListening)
          _speechRecognition.stop().then(
                (result) => setState(() {
              _isListening = result;
              resultText = "";
            }),
          );
        if (_isAvailable && !_isListening) {
          _speechRecognition
              .listen(locale: "ru_RU")
              .then((result){
                setState(() {
                  resultText = result;
                  print(resultText + " ok Google");
                });
              }
           );
        }
        else{

        }
      },
      backgroundColor: Colors.pink,
    ),
  );
}