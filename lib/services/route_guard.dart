import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/login_signup_page.dart';
import '../pages/donor_home_page.dart';
import '../pages/receiver_home_page.dart';

class RouteGuard {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if user is authenticated and redirect to appropriate page
  static Future<Widget> checkAuthStatus() async {
    User? user = _auth.currentUser;
    
    if (user == null) {
      return LoginSignupPage();
    }
    
    // User is authenticated, check user type
    try {
      // Check if user is a restaurant
      final restaurantDoc = await _firestore
          .collection('restaurants')
          .doc(user.uid)
          .get();
      
      if (restaurantDoc.exists) {
        return DonorHomePage();
      }
      
      // Check if user is an NGO
      final ngoDoc = await _firestore
          .collection('ngos')
          .doc(user.uid)
          .get();
      
      if (ngoDoc.exists) {
        return ReceiverHomePage();
      }
      
      // If user type not found, log out and return to login
      await _auth.signOut();
      return LoginSignupPage();
    } catch (e) {
      // If error occurs, log out and return to login
      await _auth.signOut();
      return LoginSignupPage();
    }
  }
} 