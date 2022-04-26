import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/screens/home_screen.dart';
import '../signup/signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _auth = FirebaseAuth.instance;

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
                  loginText(),
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

  Padding loginText() => const Padding(
      padding: EdgeInsets.only(top: 50.0),
      child: Text(
        'Login',
        style: TextStyle(color: Colors.white, fontSize: 25.0),
      ),
    );

  Padding buildTextFormFieldEmail() => Padding(
      padding: const EdgeInsets.only(top: 80.0),
      child: TextFormField(
        autofocus: false,
        controller: emailController,
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
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            )),
      ),
    );

  Padding buildTextFormFieldPassword() => Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: TextFormField(
        autofocus: false,
        controller: passwordController,
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
          passwordController.text = value!;
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
            signIn(emailController.text, passwordController.text);
          },
          child: const Text(
            'Login',
            style: TextStyle(
              fontSize: 20.0,
              fontFamily: 'Montserrat',
              color: Colors.black,
            ),
          ),
        ),
      ),
    );

  Padding bottomText(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Dont have an account?',
            style: TextStyle(fontFamily: 'Montserrat'),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SignUpScreen()));
            },
            child: const Text(
              'SignUp',
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

  void signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) => {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const HomeScreen())),
              });
    }
  }
}
