import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'pages/login_signup_page.dart';
import 'pages/splash_screen.dart';
import 'pages/donor_home_page.dart';
import 'pages/receiver_home_page.dart';
import 'services/auth_service.dart';

// Create a global AuthService instance
final AuthService authService = AuthService();
// Create a global FirebaseAnalytics instance
final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    
    // Initialize Analytics
    await analytics.setAnalyticsCollectionEnabled(true);
    print('Firebase Analytics initialized');
    
    // Test Firestore connection
    try {
      // Add a test document to test collection
      await FirebaseFirestore.instance.collection('test').add({
        'message': 'Firestore connection test',
        'timestamp': FieldValue.serverTimestamp(),
      }).then((docRef) async {
        print('Firestore connection test succeeded with ID: ${docRef.id}');
        // Delete the test document
        await docRef.delete();
        print('Test document deleted');
      });
    } catch (e) {
      print('Error testing Firestore connection: $e');
      // Continue even if Firestore test fails
    }
  } catch (e) {
    print('Failed to initialize Firebase: $e');
    // Continue without Firebase for development
  }
  
  runApp(const FoodDonationApp());
}

class FoodDonationApp extends StatelessWidget {
  const FoodDonationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Donation App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.green, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    // Show splash screen briefly
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    }
    
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        // User is not logged in
        if (!snapshot.hasData) {
          return LoginSignupPage();
        }
        
        // User is logged in, determine user type and route to appropriate home page
        return FutureBuilder<String?>(
          future: authService.getUserType(),
          builder: (context, userTypeSnapshot) {
            if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final userType = userTypeSnapshot.data;
            
            if (userType == 'restaurant') {
              return DonorHomePage();
            } else if (userType == 'ngo') {
              return ReceiverHomePage();
            } else {
              // If user type cannot be determined, sign out and return to login
              authService.signOut();
              return LoginSignupPage();
            }
          },
        );
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade400,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Food Donation",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.orange.shade800,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}