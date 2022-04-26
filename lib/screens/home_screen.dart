import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/auth/signin/signin_screen.dart';
import 'package:notes_app/screens/add_notes.dart';
import 'package:notes_app/screens/view_notes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Color> myColors = [
    Colors.yellow[200]!,
    Colors.red[200]!,
    Colors.green[200]!,
    Colors.deepPurple[200]!,
    Colors.cyan[200]!,
  ];
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      floatingActionButton: buildFloatingActionButton(context),
      body: notes_card(),
    );
  }

  AppBar customAppBar() {
    return AppBar(
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
        saveButton(),
      ],
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
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
  }

  StreamBuilder<QuerySnapshot<Object?>> notes_card() {
    return StreamBuilder<QuerySnapshot>(
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
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewNotes(
                          data: data,
                          reference: snapshot.data!.docs[index].reference,
                        ),
                      ),
                    );
                  },
                  child: customCard(bg, data, myDateTime),
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
  }

  Card customCard(Color bg, Map<dynamic, dynamic> data, DateTime myDateTime) {
    return Card(
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
  }

  IconButton saveButton() {
    return IconButton(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SignInScreen()));
      },
      icon: const Icon(
        Icons.logout_rounded,
        size: 30.0,
      ),
    );
  }
}
