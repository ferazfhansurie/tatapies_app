// ignore_for_file: unused_field, unnecessary_null_comparison

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:juta_app/home.dart';
import 'package:juta_app/utils/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _selected = false;
  bool _isLoading = false;
  bool info = false;
  void init() {

  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
        
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Container(
                width: double.infinity,
              height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 55,
                      ),
                      Container(
                           height: 100,
                           width: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/images/logo2.png',
                       
                              fit: BoxFit.contain,),
                        ),
                      ),
          SizedBox(
                        height: 55,
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
        
                              Container(
                                decoration: BoxDecoration(
                         
                                    border: Border.all( color: Color(0xFF2D3748),),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: TextField(
                                    style: TextStyle( color: Color(0xFF2D3748),
                                             fontFamily: 'SF',), 
                                    cursorColor: Color(0xFF2D3748),
                                    decoration:
                                        InputDecoration.collapsed(hintText: "Email address",hintStyle: TextStyle( color: Color(0xFF2D3748),),fillColor:Colors.white ),
                                    controller: _usernameController,
                                  ),
                                ),
                              ),
                              SizedBox(height: 15,),
         Container(
                                decoration: BoxDecoration(
                             
                                    border: Border.all( color: Color(0xFF2D3748),),
                                    borderRadius: BorderRadius.circular(8)),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: TextField(
                                    style: TextStyle( color: Color(0xFF2D3748),
                                             fontFamily: 'SF',), 
                                    obscureText: true,
                                    cursorColor: Color(0xFF2D3748),
                                    decoration:
                                        InputDecoration.collapsed(hintText: "Password",hintStyle: TextStyle( color: Color(0xFF2D3748),
                                             fontFamily: 'SF',)),
                                    controller: _passwordController,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ),
                        SizedBox(
                          height: 55,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal:15.0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFF0F5540),
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: GestureDetector(
                                onTap: () {
                                  _login(context);
                                },
                                child: Text(
                                  'Log in',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                             fontFamily: 'SF',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        
            ],
          ),
        ),
      ),
    );
  }

 

  Future<void> _login(BuildContext context) async {
    final GlobalKey progressDialogKey = GlobalKey<State>();
    ProgressDialog.show(context, progressDialogKey);
    String username = _usernameController.text;
    final user = await _auth.signInWithEmailAndPassword(
        email: username, password: _passwordController.text);
  
    ProgressDialog.unshow(context, progressDialogKey);
    if (user != null) {
      Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
        return const Home();
      }));
    }
  }
}
