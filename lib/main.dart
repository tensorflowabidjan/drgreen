import 'package:camera/camera.dart';
import 'package:dr_green/camera/camera_view.dart';
import 'package:dr_green/camera/constants.dart';
import 'package:dr_green/camera/storage.dart';
import 'package:dr_green/camera/user_model.dart';
import 'package:dr_green/detection/home.dart';
import 'package:dr_green/map/google_maps.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

List<CameraDescription> cameras;
Future<void> main() async {
	try {
		WidgetsFlutterBinding.ensureInitialized();
		cameras = await availableCameras();
	} on CameraException catch (e) {
		print('Error: $e.code\nError Message: $e.message');
	}
	final FirebaseStorage storage = await initStorage(STORAGE_BUCKET);
	final FirebaseStorage autoMlStorage = await initStorage(AUTOML_BUCKET);

	runApp(new MyApp(
		storage: storage,
		autoMlStorage: autoMlStorage
	));
}

class MyApp extends StatelessWidget {
	final FirebaseStorage storage;
  	final FirebaseStorage autoMlStorage;

	const MyApp({
		Key key,
		@required this.storage,
		@required this.autoMlStorage
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return ChangeNotifierProvider<UserModel>(
			create: (_) => UserModel(),
			child: InheritedStorage(
				storage: storage,
				autoMlStorage: autoMlStorage,
				child: MaterialApp(
					title: 'Dr Green',
					theme: ThemeData(
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
									CameraView()

									//BaseGoogleMap().getWidget(),
									// AdvicesPage(),
									//AboutPage()
								],
							),
						),
					),
					debugShowCheckedModeBanner: false,
				),
			),
		);
	}
}
