
import 'dart:async';
import 'dart:io';
import './Colordetect.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test Recognition',
      theme: ThemeData(
       
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});


  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
   bool _isPermissionGranted = false;

   late final Future<void> _future;
   final photos = <File>[];

   ColorDetectState _colorDetectState = ColorDetectState();
  Timer? _timer; // Cria o Timer
  int _durationInSeconds = 20; // Armazena o tempo máximo de duração do timer
  int _elapsedSeconds = 0; // Responsável por determinar o tempo atual em segundos
  static int _intervalo = 5;

   CameraController? _cameraController;

   final _textRecognizer = TextRecognizer();

   @override
   void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _future = _requestCameraPermission();
    _scanImage();
   }

   @override
   void dispose() {
     WidgetsBinding.instance.removeObserver(this);  
     _stopCamera();
     _textRecognizer.close();
     super.dispose();
   
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
       if (_cameraController == null || _cameraController!.value.isInitialized) {
        return;
       }
       
       if (state == AppLifecycleState.inactive){
          _stopCamera();
       } else if (state == AppLifecycleState.resumed && 
            _cameraController != null && 
            _cameraController!.value.isInitialized) {
              _startCamera();
            }
    }
   
    

   @override
   Widget build(BuildContext context) {
       return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
           return Stack(
             children: [
              if (_isPermissionGranted)
                FutureBuilder<List<CameraDescription>>(
                  future: availableCameras(),
                  builder: (context, snapshot){
                     if (snapshot.hasData) {
                        _initCameraController(snapshot.data!);

                        return Center(child: CameraPreview(_cameraController!));
                     } else {
                        return const LinearProgressIndicator();
                     }
                  }
               ),
               Scaffold(
                  appBar: AppBar(
                    title: const Text('Text Recognition Sample'),
                  ),
                  backgroundColor: _isPermissionGranted ? Colors.transparent : null ,
                  body: _isPermissionGranted
                  ? Column( 
                     children: [
                        Expanded(child: Container(),
                        ),
                        Container(
                           padding: const EdgeInsets.only(bottom: 30.0),
                           child: Center(
                            child: ElevatedButton(
                               onPressed: _scanImage,
                               child: Text('Scan text'),
                              ),
                         ),
                        )                      
                    ],
               ) 
                  : Center(
                     child: Container(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0,),
                        child: const Text('Camera permission denied',
                               textAlign:  TextAlign.center,
                        ),
                     ) ,
                     )
          )
             ],
           );
          }, 
        );
   }

    Future<void> _requestCameraPermission() async {
     final status = await Permission.camera.request();
     _isPermissionGranted = status == PermissionStatus.granted;
   }

   void _startCamera() {
     if (_cameraController != null){
        _cameraSelected(_cameraController!.description);       
     }
   }


   void _stopCamera() {
     if (_cameraController != null) {
        _cameraController?.dispose();
     }
   }

     
   void _initCameraController(List<CameraDescription> cameras) {
         if (_cameraController != null) {
          return;    
         }

         CameraDescription? camera;
         for (var i = 0; i < cameras.length; i++) {
            final CameraDescription current = cameras[i];
            if (current.lensDirection == CameraLensDirection.back) {
               camera = current;
               break;
            }
         }

         if (camera != null) {
          _cameraSelected(camera);
         }
   }
   
   Future<void> _cameraSelected(CameraDescription camera) async {
     _cameraController = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      );

      await _cameraController?.initialize();

      if (!mounted) {
        return;
      }
      setState(() {});
   }
    var x = 0;
    Future<void> _scanImage() async {

       _timer = Timer.periodic(Duration(seconds: _intervalo), (timer) async {
      if (_cameraController == null) return;

      final navigator =  Navigator.of(context);

     // try {
         final pictureFile = await _cameraController!.takePicture();

         final file = File(pictureFile.path);

         final inputImage = InputImage.fromFile(file);
         print(file);
         photos.add(file);
         var temp = photos[x]; //--> Bota em uma variavel temporada a foto atual do array de fotos
                    x++; // Movimenta a posição do array de Fotos

                    dynamic bytes = Uint8List.fromList(temp.readAsBytesSync());
                   var hex = _colorDetectState.get_pixel_color(bytes);
                    print("O valor do hexadecimal $hex");

                    //dynamic imgBase64 = base64Encode(bytes);
                    //var imgDecode64 = base64Decode(imgBase64.toString());
                    //Image foto = Image.memory(base64Decode(imgBase64));
                    //String string = String.fromCharCodes(bytes);

                    //var img = await rootBundle.load(foto);

                    var decodedImage =
                        await decodeImageFromList(bytes.buffer.asUint8List());
                    int imgWidth = decodedImage.width;
                    int imgHeight = decodedImage.height;
           
               

                    //print('foto $bytes'); --> Mostra os bytes da fotos

                    /* 
                    Navigator.pop(context);
                    setState(() {});*/

                    print("==================\n==================\n");
                    print("O que está acontecendo agora");
                    print(photos);
                    print(_elapsedSeconds);
                    print(_durationInSeconds);
                    print('Width $imgWidth Height $imgHeight');
                    //print("Hexadecimal da cor:");
                    //print(_colorDetectState.get_pixel_color(bytes));
                    print("==================\n==================\n");
         //final RecognizedText = await _textRecognizer.processImage(inputImage);

         /*await navigator.push(
          MaterialPageRoute(builder: (context) => ResultScreen(text: RecognizedText.text),
          )
         );*/
     // }catch (e) {
       // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
       //   content: Text('An error occurred when scanning text'),
        //),
       // );

      //}
      _elapsedSeconds+=_intervalo;
                  
                    if (_elapsedSeconds >= _durationInSeconds) {
                      _timer?.cancel();
                      print("Timer finished");
                      photos.clear();
                    }
      });
    }
   
}
