import 'package:camera/camera.dart';
import 'package:dr_green/camera/camera_screen.dart';
import 'package:dr_green/detection/home.dart';
import 'package:dr_green/map/google_maps.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras;
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dr Green',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Dr Green'),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  text: "Identifier",
                ),
                Tab(
                  text: "Maps",
                ),
                Tab(
                  text: "Prendre une photo",
                ),
                //  Tab(
                //   text: "About",
                //  ),
              ],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              HomePage(cameras),
              MyHomePage(),
              CameraScreen(),
              //BaseGoogleMap().getWidget(),
              // AdvicesPage(),
              //AboutPage()
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
