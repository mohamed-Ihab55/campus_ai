import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<User?>? _authSubscription;

  AuthCubit() : super(const AuthInitial()) {
    listenToAuthChanges();
  }
  void listenToAuthChanges() {
    _authSubscription?.cancel();

    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;

      if (user == null) {
        emit(const AuthError('Failed to create account'));
        return;
      }
      await user.updateDisplayName(name);

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
  
  
  Future<void> login({required String email, required String password,}) async{
    try{
      emit(AuthLoading());
      
      final credential= await _auth.signInWithEmailAndPassword(email: email.trim(),
          password: password.trim());
      final user=credential.user;
      
      if(user==null){
        emit(AuthError('Login failed'));
        return;
      }

      emit(AuthAuthenticated(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }


  Future<void> resetPassword(String email) async {
    try {
      emit(AuthLoading());

      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

      emit(const AuthSuccess('Password reset email sent'));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }


  Future<void> logout() async {
    await _auth.signOut();
    emit(const AuthUnauthenticated());
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());

    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      final userCredential =
      await FirebaseAuth.instance.signInWithProvider(googleProvider);

      final user = userCredential.user;

      if (user != null) {
        // optional: save user in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'photo': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      emit(AuthAuthenticated(user!));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  String _mapFirebaseError(String code){
    switch (code){
      case 'email-already-in-use':
        return 'Email already in use';

      case 'invalid-email':
        return 'Invalid email';

      case 'weak-password':
        return 'Weak password';

      case 'user-not-found':
        return 'User not found';

      case 'wrong-password':
        return 'Wrong password';

      case 'invalid-credential':
        return 'Invalid credentials';

      default:
        return 'Authentication error';
    }
  }
  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
