import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notes_app/auth/signin/signin_screen.dart';
import 'package:notes_app/auth/user_model.dart';
import 'package:notes_app/screens/add_notes.dart';
import 'package:notes_app/screens/favorite_screen.dart';
import 'package:notes_app/screens/view_notes.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

  UserModel userModel = UserModel();

  File? _photo;
  final ImagePicker _picker = ImagePicker();

  bool isUpdate = false;

    Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        updateProfile();
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final fileName = basename(_photo!.path);
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('uploads/$fileName');
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occured');
    }
  }

    void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Gallery'),
                    onTap: () {
                      chooseImage();
                      Navigator.pop(context);
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  List<Color> myColors = [
    Colors.yellow[200]!,
    Colors.red[200]!,
    Colors.green[200]!,
    Colors.deepPurple[200]!,
    Colors.cyan[200]!,
    Colors.purpleAccent[200]!,
    Colors.tealAccent[200]!,
  ];

  UserModel logedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.email)
        .get()
        .then((value) =>
    {
      logedInUser = UserModel.fromMap(value.data()),
      setState(() {}),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context),
      floatingActionButton: buildFloatingActionButton(context),
      body: notes_card(),
      drawer: drawer(context),
    );
  }

  Drawer drawer(BuildContext context) =>
      Drawer(
        backgroundColor: Colors.grey,
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                '${logedInUser.name}',
                style: TextStyle(color: Colors.black, fontSize: 20.0),
              ),
              accountEmail: Text(
                '${logedInUser.email}',
                style: TextStyle(color: Colors.grey[700], fontSize: 15.0),
              ),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  _showPicker(context);
                },
                child: CircleAvatar(
                  radius: 30,
                  child: _photo != null
                      ? CircleAvatar(
                    radius: 50.0,
                    backgroundImage: FileImage(
                      _photo!,
                    ),
                  )
                      : CircleAvatar(
                    radius: 50.0,
                    backgroundImage: NetworkImage(logedInUser.photoUrl.toString(),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.only(top: 15.0, left: 15.0),
              title: const Text(
                'Favorite',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.0,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoriteScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      );

  AppBar customAppBar(BuildContext context) =>
      AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xff070706),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignInScreen()));
            },
            icon: const Icon(
              Icons.logout_rounded,
              size: 30.0,
            ),
          ),
        ],
      );

  FloatingActionButton buildFloatingActionButton(BuildContext context) =>
      FloatingActionButton(
        child: const Icon(
          Icons.add,
          color: Colors.white70,
        ),
        backgroundColor: Colors.grey[700],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNotes(),
            ),
          );
        },
      );

  StreamBuilder<QuerySnapshot<Object?>> notes_card() =>
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.email)
            .collection('notes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                Random random = Random();
                Color bg = myColors[random.nextInt(4)];
                Map? data = snapshot.data!.docs[index].data() as Map?;
                DateTime myDateTime = data!['created'].toDate();
                return Slidable(
                  startActionPane:
                  ActionPane(motion: const ScrollMotion(), children: [
                    SlidableAction(
                      onPressed: (BuildContext context) async {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUser!.email)
                            .collection('favorite')
                            .add({
                          'title': data['title'],
                          'description': data['description'],
                          'created': DateTime.now(),
                        });
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FavoriteScreen()));
                      },
                      backgroundColor: Colors.green,
                      label: 'Favorite',
                      icon: Icons.favorite,
                    ),
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 5.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewNotes(
                                  data: data,
                                  reference: snapshot.data!.docs[index]
                                      .reference,
                                ),
                          ),
                        );
                      },
                      child: customCard(bg, data, myDateTime),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text('Loading...'),
          );
        },
      );

  Card customCard(Color bg, Map<dynamic, dynamic> data, DateTime myDateTime) =>
      Card(
        color: bg,
        shadowColor: Colors.white,
        elevation: 5.0,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data['title']}',
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: Text(
                  myDateTime.toString(),
                  style: const TextStyle(fontSize: 20.0, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      );

  updateProfile() async {
    String url = "";
    try {
      setState(() {
        isUpdate = true;
      });
      if (_photo != null) {
        url = await uploadImage();
      }
      await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser?.email)
          .update({'photoUrl': url});
      setState(() {
        isUpdate = false;
      });
    }catch(e){
      setState(() {
        isUpdate = false;
      });
    }
  }

  chooseImage() async {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    _photo = File(xFile!.path);
    setState(() {
      updateProfile();
    });
  }

  Future<String> uploadImage() async {
    TaskSnapshot taskSnapshot = await FirebaseStorage.instance
        .ref()
        .child("profile")
        .child(currentUser!.uid + "_" + basename(_photo!.path))
        .putFile(_photo!);

    return taskSnapshot.ref.getDownloadURL();
  }

}

