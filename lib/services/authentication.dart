import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationHelper{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  get user => _auth.currentUser;


  Future signIn({required String email, required String password}) async{
    try{
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch(e){
      return e.message;
    }
  }


  Future signUp({
    required String name,
    required String phone,
    required String address,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      await user?.updateDisplayName(name);
      await user?.reload();

      await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
        'uid': user?.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'createdAt': Timestamp.now(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Something went wrong';
    }
  }



  Future signOut() async{
    await _auth.signOut();
  }


  Future resetPasswordByEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch(e){
      return e.message;
    }
  }



}