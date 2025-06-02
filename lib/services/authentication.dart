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


  Future signUp({required String name,required String email, required String password}) async {
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();

      return null;
    } on FirebaseAuthException catch(e){
      return e.message;
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