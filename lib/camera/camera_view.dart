import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dr_green/camera/datasets_list.dart';
import 'package:dr_green/camera/intro_tutorial.dart';
import 'package:dr_green/camera/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CameraView extends StatefulWidget {
	@override
	_CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
	final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
	final query = Firestore.instance.collection('datasets');

	@override
	Widget build(BuildContext context) {
		final userModel = Provider.of<UserModel>(context);
		return Scaffold(
			key: _scaffoldKey,
			appBar: new AppBar(
				title: new Text("Datasets"),
				actions: <Widget>[
				if (!userModel.isLoggedIn())
					IconButton(
						onPressed: () {
							userModel
								.beginSignIn()
								.then((user) => userModel.setLoggedInUser(user))
								.catchError((e) => print(e));
						},
						icon: Icon(
							Icons.person_outline,
						),
					),
				userModel.isLoggedIn()
					? PopupMenuButton<MainAction>(
						onSelected: (MainAction action) {
							switch (action) {
							case MainAction.logout:
								userModel.logOut();
								break;
							case MainAction.viewTutorial:
								Navigator.pushNamed(context, IntroTutorial.routeName);
								break;
							}
						},
						itemBuilder: (BuildContext context) =>
							<PopupMenuItem<MainAction>>[
							PopupMenuItem<MainAction>(
							child: Text.rich(
								TextSpan(
								text: 'Logout',
								children: [
									TextSpan(
									text: " (${userModel.user.displayName})",
									style: TextStyle(
										color: Colors.black38,
										fontStyle: FontStyle.italic,
									),
									)
								],
								),
							),
							value: MainAction.logout,
							),
							const PopupMenuItem<MainAction>(
							child: Text('View Tutorial'),
							value: MainAction.viewTutorial,
							)
						],
					)
					: Container()
				],
			),
			body: DatasetsList(
				scaffoldKey: _scaffoldKey,
				query: userModel.isLoggedIn()
					? query
					: query.where('isPublic', isEqualTo: true),
				model: userModel,
			),
		);
	}
}

enum MainAction { logout, viewTutorial }