import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseService _databaseService = DatabaseService();

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String regNumber,
    required bool isRestaurant,
  }) async {
    try {
      print('Attempting to register with email: $email');
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      print('User registered successfully with UID: ${userCredential.user!.uid}');
      
      // Store additional user information in Firestore based on user type
      if (isRestaurant) {
        await _databaseService.saveRestaurantData(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          regNumber: regNumber,
        );
      } else {
        await _databaseService.saveNGOData(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          regNumber: regNumber,
        );
      }
      
      print('User data saved to Firestore successfully');
      return userCredential;
    } catch (e) {
      print('Error in registration: $e');
      rethrow; // Re-throw the exception to be caught by the UI
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      print('Error in login: $e');
      rethrow;
    }
  }

  // Sign in with ID
  Future<UserCredential> signInWithID(
    String id,
    String password,
    bool isRestaurant,
  ) async {
    try {
      // Determine which collection to query based on user type
      String collectionPath = isRestaurant ? 'restaurants' : 'ngos';
      
      // Determine which field to query based on user type
      String fieldName = isRestaurant ? 'FAASI' : 'reg no.';
      
      // Query Firestore to find the user with the given ID
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where(fieldName, isEqualTo: id)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this ID',
        );
      }
      
      // Get the email from the document
      String email = querySnapshot.docs[0]['email'];
      
      // Sign in with the email and password
      return await signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with ID: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get user type (restaurant or ngo)
  Future<String?> getUserType() async {
    try {
      if (currentUser == null) return null;
      
      // Check if user exists in restaurants collection
      DocumentSnapshot restaurantDoc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(currentUser!.uid)
          .get();
      
      if (restaurantDoc.exists) {
        return 'restaurant';
      }
      
      // Check if user exists in ngos collection
      DocumentSnapshot ngoDoc = await FirebaseFirestore.instance
          .collection('ngos')
          .doc(currentUser!.uid)
          .get();
      
      if (ngoDoc.exists) {
        return 'ngo';
      }
      
      return null;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
} 