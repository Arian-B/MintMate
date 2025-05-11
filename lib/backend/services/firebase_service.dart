import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app;

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  // Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login timestamp
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Register with email and password
  static Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      final user = app.User(
        id: userCredential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.id).set(user.toFirestore());

      return userCredential;
    } catch (e) {
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
} 