import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Reference to restaurants collection
  CollectionReference get restaurantsCollection => 
      _firestore.collection('restaurants');
      
  // Reference to NGOs collection
  CollectionReference get ngosCollection => 
      _firestore.collection('ngos');
  
  // Reference to donations collection
  CollectionReference get donationsCollection => 
      _firestore.collection('donations');

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Save restaurant user data
  Future<void> saveRestaurantData({
    required String uid,
    required String name,
    required String email,
    required String regNumber,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      await restaurantsCollection.doc(uid).set({
        'name': name,
        'email': email,
        'FAASI': regNumber,
        'userType': 'restaurant',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('Restaurant data saved successfully for UID: $uid');
    } catch (e) {
      print('Error saving restaurant data: $e');
      throw e;
    }
  }

  // Save NGO user data
  Future<void> saveNGOData({
    required String uid,
    required String name,
    required String email,
    required String regNumber,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      await ngosCollection.doc(uid).set({
        'name': name,
        'email': email,
        'reg no.': regNumber,
        'FAASI': '',
        'userType': 'ngo',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('NGO data saved successfully for UID: $uid');
    } catch (e) {
      print('Error saving NGO data: $e');
      throw e;
    }
  }

  // Get user data (restaurant or NGO)
  Future<DocumentSnapshot?> getUserData(String uid, String userType) async {
    try {
      if (userType == 'restaurant') {
        return await restaurantsCollection.doc(uid).get();
      } else if (userType == 'ngo') {
        return await ngosCollection.doc(uid).get();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      throw e;
    }
  }

  // Create a new donation
  Future<void> createDonation({
    required String restaurantId,
    required String foodItem,
    required int quantity,
    required String expiryDate,
    required String pickupAddress,
    String? description,
  }) async {
    try {
      await donationsCollection.add({
        'restaurantId': restaurantId,
        'foodItem': foodItem,
        'quantity': quantity,
        'expiryDate': expiryDate,
        'pickupAddress': pickupAddress,
        'description': description ?? '',
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
        'ngoId': null,
        'claimedAt': null,
      });
      print('Donation created successfully');
    } catch (e) {
      print('Error creating donation: $e');
      throw e;
    }
  }

  // Get all available donations
  Stream<QuerySnapshot> getAvailableDonations() {
    return donationsCollection
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get my donations (for restaurants)
  Stream<QuerySnapshot> getMyDonations() {
    String? uid = currentUserId;
    if (uid == null) return Stream.value(null as QuerySnapshot);
    
    return donationsCollection
        .where('restaurantId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Get claimed donations (for NGOs)
  Stream<QuerySnapshot> getClaimedDonations() {
    String? uid = currentUserId;
    if (uid == null) return Stream.value(null as QuerySnapshot);
    
    return donationsCollection
        .where('ngoId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Claim a donation (for NGOs)
  Future<void> claimDonation(String donationId) async {
    String? uid = currentUserId;
    if (uid == null) throw Exception('User not logged in');
    
    try {
      await donationsCollection.doc(donationId).update({
        'ngoId': uid,
        'status': 'claimed',
        'claimedAt': FieldValue.serverTimestamp(),
      });
      print('Donation claimed successfully');
    } catch (e) {
      print('Error claiming donation: $e');
      throw e;
    }
  }
} 