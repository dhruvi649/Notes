import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/screens/home_screen.dart';
import '../signin/signin_screen.dart';
import '../user_model.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isObscure = true;

  final _formKey = GlobalKey<FormState>();
  final nameEditingController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  signupText(),
                  buildTextFormFieldUname(),
                  buildTextFormFieldEmail(),
                  buildTextFormFieldPassword(),
                  buildMaterial(context),
                  bottomText(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding signupText() => const Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Text(
        'Create your account',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
          fontSize: 25.0,
        ),
      ),
    );

  Padding buildTextFormFieldUname() => Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: TextFormField(
        autofocus: false,
        controller: nameEditingController,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please enter your username");
          }
          return null;
        },
        onSaved: (value) {
          nameEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: "Username",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

  Padding buildTextFormFieldEmail() => Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: TextFormField(
        autofocus: false,
        controller: emailEditingController,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please enter your email");
          }
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Please enter a valid email");
          }
          return null;
        },
        onSaved: (value) {
          emailEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: "Email",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );

  Padding buildTextFormFieldPassword() => Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: TextFormField(
        autofocus: false,
        controller: passwordEditingController,
        validator: (value) {
          RegExp regex = RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Please enter your password");
          }
          if (!regex.hasMatch(value)) {
            return ("Please enter valid password(Minimum 6 character)");
          }
          return null;
        },
        obscureText: _isObscure,
        onSaved: (value) {
          passwordEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: IconButton(
              icon: Icon(
                _isObscure ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              }),
        ),
      ),
    );

  Padding buildMaterial(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: Material(
        elevation: 5,
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(30),
        child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            SignUp(emailEditingController.text, passwordEditingController.text);
          },
          child: const Text(
            'SignUp',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );

  Padding bottomText(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Already have an account?',
            style: TextStyle(
              fontFamily: 'Montserrat',
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignInScreen()));
            },
            child: const Text(
              'Login',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.blue,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );

  void SignUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {
                postDetailsToFirestore(),
              });
    }
  }

  postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();

    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.name = nameEditingController.text;
    userModel.password = passwordEditingController.text;
    userModel.photoUrl = 'assets/images/profile.jpg';

    await firebaseFirestore
        .collection("users")
        .doc(user.email)
        .set(userModel.toMap());

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}
