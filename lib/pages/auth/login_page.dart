
import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/pages/auth/register_page.dart';
import 'package:chatapp_firebase/pages/home_page.dart';
import 'package:chatapp_firebase/service/auth_service.dart';
import 'package:chatapp_firebase/service/database_service.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';




class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  AuthService authService = AuthService();
  bool _isLoading = false;
 
  final _formKey = GlobalKey<FormState>();
  String email=" ";
  String pass=" ";
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:_isLoading? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:20, vertical:80),
          child: Form(
                key: _formKey,
                child:  Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Groupie", style:TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Center(
              child: const Text("Login now to see what they are talking!",style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w400
              ),),
            ),
              Image.asset("assets/login.png"),
              TextFormField(
                decoration: textInputDecoration.copyWith(labelText: "Email",
                prefixIcon: Icon(
                  Icons.email,
                  color: Theme.of(context).primaryColor,
                )),
                onChanged: (val){
                  setState(() {
                    email= val;
                  });
                  

                },
                validator: (val) {
                   return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val!)
                                ? null
                                : "Please enter a valid email";

                },


              ),
              
              const SizedBox(height: 15),
              TextFormField(
                obscureText: true,
                decoration: textInputDecoration.copyWith(labelText: "Password",
                prefixIcon: Icon(
                  Icons.lock,
                  color: Theme.of(context).primaryColor,
                )),
                onChanged: (val){
                  setState(() {
                    pass= val;
                    
                  });
                },
                validator: (val) {
                   if(val!.length<6){
                    return "Password must be at least 6 characters";

                   }
                   else{
                    return null;
                   }

                },
                



              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton( style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30))),
                            child: const Text(
                              "Sign In",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                  onPressed: (){
                    login();
                  }),
              ),
              const SizedBox(height: 10),
               Text.rich(TextSpan(
                text: "Dont't have an account? ",
                style:TextStyle(
                              color: Colors.black, fontSize: 14),
                              children: <TextSpan>[
                            TextSpan(
                                text: "Register here",
                                style:  TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline),
                                     recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    nextScreen(context, const RegisterPage());
                                  }
                                ),
                                
                          ],


              ))



          ],
                ),
              ),
        )
      )

    );

  }
  login() async{
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await authService
          .loginUser( email, pass)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot = await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).getUserData(email);
          HelperFunction.setUserLoggedInStatus(value);
          HelperFunction.setUserNameSF( snapshot.docs[0]['fullName']);
          HelperFunction.setUserEmailSF( email);
          nextScreen(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      });
    }
  }
}