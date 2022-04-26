import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewNotes extends StatefulWidget {
  final Map data;
  final DocumentReference reference;

  const ViewNotes({
    Key? key,
    required this.data,
    required this.reference,
  }) : super(key: key);

  @override
  _ViewNotesState createState() => _ViewNotesState();
}

class _ViewNotesState extends State<ViewNotes> {
  late String title;
  late String description;
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    setState(() {
      _title.text = widget.data['title'];
      _description.text = widget.data['description'];
    });
  }

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customButton(context),
                  titleDescriptionTextFormField(context),
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
        Row(
          children: [
            addNotesButton(),
            const SizedBox(
              width: 10.0,
            ),
            updateNotes(),
          ],
        ),
      ],
    );
  }

  Padding titleDescriptionTextFormField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Form(
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
      ),
    );
  }

  TextFormField descriptionTextFormField() {
    return TextFormField(
      decoration: const InputDecoration.collapsed(hintText: 'description'),
      style: const TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
      controller: _description,
      maxLines: 20,
    );
  }

  TextFormField titleTextFormField() {
    return TextFormField(
      decoration: const InputDecoration.collapsed(hintText: 'title'),
      style: const TextStyle(
        fontSize: 32.0,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
      controller: _title,
    );
  }

  ElevatedButton addNotesButton() {
    return ElevatedButton(
      onPressed: () async {
        await widget.reference.delete();

        Navigator.pop(context);
      },
      child: const Icon(
        Icons.delete,
        color: Colors.white,
      ),
      style: ElevatedButton.styleFrom(
        primary: Colors.redAccent,
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 8.0,
        ),
      ),
    );
  }

  ElevatedButton updateNotes() {
    return ElevatedButton(
      onPressed: () async {
        await widget.reference.update({
          'title': _title.text,
          'description': _description.text,
        });
        Navigator.pop(context);
      },
      child: const Text(
        'Update',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 8.0,
        ),
      ),
    );
  }
}
