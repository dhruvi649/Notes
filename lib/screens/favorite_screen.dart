import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/screens/view_notes.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Color> myColors = [
    Colors.yellow[200]!,
    Colors.red[200]!,
    Colors.green[200]!,
    Colors.deepPurple[200]!,
    Colors.cyan[200]!,
    Colors.purpleAccent[200]!,
    Colors.tealAccent[200]!,
  ];
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: favoriteList(),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> favoriteList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.email)
          .collection('favorite')
          .snapshots(),
      builder: (context, snapshot) {
        return listViewFavorite(snapshot);
      },
    );
  }

  ListView listViewFavorite(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        Random random = Random();
        Color bg = myColors[random.nextInt(4)];
        Map? data = snapshot.data!.docs[index].data() as Map?;
        DateTime myDateTime = data!['created'].toDate();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
}
