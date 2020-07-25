import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_recognition/speech_recognition.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build ithu nphaan
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('TransBotter',
              style: GoogleFonts.lato(
                fontSize: 25,
                fontWeight: FontWeight.w700,
              )),
          backgroundColor: Colors.deepPurple[800],
        ),
        backgroundColor: Colors.cyan[50],
        body: MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _Mainpage createState() => _Mainpage();
}

class _Mainpage extends State<MainPage> {
  bool _isimageVisible = false;
  bool _istextVisible = false;
  bool _istVisible = false;
  bool _isVisible = false;
  bool _isresultVisible = false;
  String dropdownValue = 'en';
  final _controller = TextEditingController();
  final picker = ImagePicker(); //Image selector function
  File pickedImage;
  bool isImageLoaded = false;
  String textInput = ' ';
  final FlutterTts flutterTts = FlutterTts();
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;
  var resultText = "Not translated";
  String tf = "";
  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

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

  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void showImageToast() {
    setState(() {
      if (_isimageVisible) {
        _isimageVisible = _isimageVisible;
      } else {
        _isimageVisible = !_isimageVisible;
      }
    });
  }

  void showTToast() {
    setState(() {
      if (_istVisible) {
        _istVisible = _istVisible;
      } else {
        _istVisible = !_istVisible;
      }
    });
  }

  void showTextToast() {
    setState(() {
      if (_istextVisible) {
        _istextVisible = _istextVisible;
      } else {
        _istextVisible = !_istextVisible;
      }
    });
  }

  void showToast() {
    setState(() {
      if (_isVisible) {
        _isVisible = _isVisible;
      } else {
        _isVisible = !_isVisible;
      }
    });
  }

  void showResultToast() {
    setState(() {
      if (_isresultVisible) {
        _isresultVisible = _isresultVisible;
      } else {
        _isresultVisible = !_isresultVisible;
      }
    });
  }

  Future<void> pickImage() async {
    final picture = await picker.getImage(
        source: ImageSource.gallery); //To get the image from gallery
    this.setState(() {
      pickedImage =
          File(picture.path); //To convert the obtaied image to a file;
    });
  }

  Future<void> readText() async {
    FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    VisionText visionText = await textRecognizer.processImage(visionImage);
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          setState(() {
            resultText = resultText + word.text + ' ';
            print('reading');
          });
        }
        resultText = resultText + '\n';
      }
    }
    print(resultText);
    textRecognizer.close();
  }

  GoogleTranslator translator =
      new GoogleTranslator(); //using google translator

  String out;
  void trans(String dropdownValue) {
    var text;
    String tt = dropdownValue;
    if (_controller.text != null) {
      text = _controller.text;
    } else {
      text = resultText;
    }
    translator.translate(resultText, to: tt) //translating to selected language
        .then((output) {
      setState(() {
        out = output; //placing the translated text to the String to be used
      });
      print(out);
      print(textInput = out.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    _speak(String text) async {
      print(await flutterTts.getLanguages);
      await flutterTts.setLanguage('en-US'); // for language
      await flutterTts.setPitch(1); // change the voice
      await flutterTts.speak(text);
    }

    // TODO: implement build
    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: new Card(
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                print('Card tapped.');
              },
              child: Container(
                  width: 300,
                  height: 90,
                  alignment: Alignment.topLeft,
                  child: Text(
                    'TransBotter at your service!Iam here to help you translate:)                                  Chose your choice of input for me.',
                    style: GoogleFonts.lato(fontSize: 17),
                  )),
            ),
          ),
        ),
        Visibility(
          visible: _isimageVisible,
          child: Align(
            alignment: Alignment.topRight,
            child: new Card(
                child: Container(
              height: 150.0,
              width: 200.0,
              child: pickedImage == null
                  ? Text('No image selected.')
                  : Image.file(pickedImage),
            )),
          ),
        ),
        Visibility(
          visible: _istextVisible,
          child: Align(
            alignment: Alignment.topRight,
            child: new Card(
                child: Container(
                    height: 200.0, width: 200.0, child: Text(resultText))),
          ),
        ),
        Visibility(
          visible: _istVisible,
          child: Align(
            alignment: Alignment.topRight,
            child: new Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    print('Card tapped.');
                  },
                  child: Container(
                    width: 250,
                    height: 100,
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(_controller.text),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Visibility(
            visible: _isVisible,
            child: new Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  print('Card tapped.');
                },
                child: Container(
                  width: 250,
                  height: 40,
                  child: new Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Select Input language ',
                            style: GoogleFonts.lato(fontSize: 17)),
                      ),
                      new Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        // dropdown below..
                        child: DropdownButton<String>(
                            value: dropdownValue,
                            isExpanded: false,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 20,
                            underline: SizedBox(),
                            onChanged: (String newValue) {
                              setState(() {
                                dropdownValue = newValue;
                              });
                              trans(dropdownValue);
                              showResultToast();
                            },
                            items: <String>['ta', 'hi', 'ko', 'en']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: _isresultVisible,
          child: Align(
            alignment: Alignment.topLeft,
            child: new Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    print('Card tapped.');
                  },
                  child: Container(
                    width: 250,
                    height: 100,
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(out.toString())),
                        IconButton(
                            icon: Icon(Icons.settings_voice),
                            color: Colors.pink,
                            onPressed: () {
                              _speak(textInput);
                            }),
                      ],
                    ),
                  ),
                )),
          ),
        ),
        Expanded(child: Container()),
        Expanded(
          child: new Row(
            children: [
              new Flexible(
                child: TextFormField(
                  maxLines: null,
                  expands: true,
                  controller: _controller,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type your input',
                    suffixIcon: IconButton(
                        onPressed: () => _controller.clear(),
                        icon: Icon(Icons.clear),
                        color: Colors.black),
                  ),
                  onFieldSubmitted: (resultText) {
                    resultText = _controller.text;
                    showToast();
                    print(resultText);
                    //call text translator
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.pinkAccent,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send),
                    color: Colors.white,
                    onPressed: () {
                      showTToast();
                      showToast();
                      //text to text translator
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.pinkAccent,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.settings_voice),
                    color: Colors.white,
                    onPressed: () {
                      if (_isAvailable && !_isListening)
                        _speechRecognition.listen(locale: "en_US").then(
                            (result) =>
                                print('$result')); //Called Voice to text module
                      showTextToast();
                      showToast();
                      print(resultText);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Ink(
                  decoration: const ShapeDecoration(
                    color: Colors.lightBlue,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.image),
                    color: Colors.white,
                    onPressed: () {
                      pickImage();
                      showImageToast();
                      readText();
                      showToast();
                      //Image to text module
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
