// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dr_green/camera/add_dataset_label_screen.dart';
import 'package:dr_green/camera/constants.dart';
import 'package:dr_green/camera/datasets_list.dart';
import 'package:dr_green/camera/intro_tutorial.dart';
import 'package:dr_green/camera/signin_page.dart';
import 'package:dr_green/camera/storage.dart';
import 'package:dr_green/camera/user_model.dart';

void main() async {
  final FirebaseStorage storage = await initStorage(STORAGE_BUCKET);
  final FirebaseStorage autoMlStorage = await initStorage(AUTOML_BUCKET);
 
  runApp(new MyApp(
    
    storage: storage,
    autoMlStorage: autoMlStorage,
    userModel: UserModel(),
  ));
}

enum MainAction { logout, viewTutorial }

class MyApp extends StatelessWidget {
  final FirebaseStorage storage;
  final FirebaseStorage autoMlStorage;
  final UserModel userModel;

  const MyApp({
    Key key,
    @required this.storage,
    @required this.autoMlStorage,
    @required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<UserModel>(
      create: (_) => userModel,
      child: new InheritedStorage(
        storage: storage,
        autoMlStorage: autoMlStorage,
        child: new MaterialApp(
          title: 'Custom Image Classifier',
          theme: new ThemeData(
            primaryColor: Colors.white,
            accentColor: Colors.deepPurple,
            dividerColor: Colors.black12,
          ),
          initialRoute: MyHome.routeName,
          routes: {
            MyHome.routeName: (context) => MyHome(),
            //IntroTutorial.routeName: (context) => IntroTutorial(),
          },
        ),
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  UserModel of(BuildContext context) => Provider.of<UserModel>(context);
  static const routeName = '/';

  const MyHome();

  @override
  _MyHomeState createState() => new _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //@override
  //void initState() {
  // super.initState();
  // checkAndShowTutorial();
  //}

  //void checkAndShowTutorial() async {
  //SharedPreferences prefs = await SharedPreferences.getInstance();
  // final seenTutorial = prefs.getBool('seenTutorial') ?? false;
  // if (!seenTutorial) {
  //   Navigator.pushNamed(context, IntroTutorial.routeName);
  // } else {
  //   print("Has seen tutorial before. Skipping");
  //}
  //}

  @override
  Widget build(BuildContext context) {
    UserModel of(BuildContext context) => Provider.of<UserModel>(context);
    final model = Provider.of<UserModel>(context);
    final query = Firestore.instance.collection('datasets');

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text("Datasets"),
        actions: <Widget>[
          if (!model.isLoggedIn())
            IconButton(
              onPressed: () {
                model
                    .beginSignIn()
                    .then((user) => model.setLoggedInUser(user))
                    .catchError((e) => print(e));
              },
              icon: Icon(
                Icons.person_outline,
              ),
            ),
          model.isLoggedIn()
              ? PopupMenuButton<MainAction>(
                  onSelected: (MainAction action) {
                    switch (action) {
                      case MainAction.logout:
                        model.logOut();
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
                              text: " (${model.user.displayName})",
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
        query: model.isLoggedIn()
            ? query
            : query.where('isPublic', isEqualTo: true),
        model: model,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      // show fab button only on personal datasets page
      floatingActionButton: new FloatingActionButton.extended(
        icon: Icon(Icons.add),
        label: Text("New Dataset"),
        onPressed: () async {
          if (model.isLoggedIn()) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddDatasetLabelScreen(DataKind.Dataset, "", "", ""),
                ));
          } else {
            // Route to login page
            final result = await Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignInPage()));
            if (result) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddDatasetLabelScreen(DataKind.Dataset, "", "", "")));
            }
          }
        },
      ),
    );
  }
}
