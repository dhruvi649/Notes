import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({Key? key}) : super(key: key);

  @override
  _AddNotesState createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  late String title;
  late String description;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  customButton(context),
                  titleDescriptionTextFormField(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Row customButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back_ios_outlined,
            size: 24.0,
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.grey[700],
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          ),
        ),
        addNotesButton(),
      ],
    );
  }

  ElevatedButton addNotesButton() {
    return ElevatedButton(
      onPressed: () async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.email)
            .collection('notes')
            .add({
          'title': _title.text,
          'description': _description.text,
          'created': DateTime.now(),
        });
        Navigator.pop(context);
      },
      child: const Text(
        'Save',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: Colors.grey[700],
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      ),
    );
  }

  Form titleDescriptionTextFormField(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          children: [
            titleTextFormField(),
            Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.only(top: 20.0),
              child: descriptionTextFormField(),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField descriptionTextFormField() {
    return TextFormField(
      controller: _description,
      decoration: const InputDecoration.collapsed(hintText: 'Description'),
      style: const TextStyle(fontSize: 20.0, color: Colors.white),
      maxLines: 20,
    );
  }

  TextFormField titleTextFormField() {
    return TextFormField(
      decoration: const InputDecoration.collapsed(hintText: 'Title'),
      style: const TextStyle(
          fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
      controller: _title,
    );
  }
}
