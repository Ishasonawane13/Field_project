import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'donor_home_page.dart';
import 'receiver_home_page.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../main.dart' show authService; // Import the global authService

class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({Key? key}) : super(key: key);
  
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();
  final _createPasswordFormKey = GlobalKey<FormState>();
  
  // Login controllers
  final _loginEmailOrIdController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  
  // Signup controllers - First Step
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupIdController = TextEditingController();
  final _signupFssaiController = TextEditingController(); // Optional for NGOs
  
  // Signup controllers - Second Step
  final _createPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSignupSecondStep = false;
  bool _passwordsMatch = true;
  bool _isRestaurantSelected = false;
  
  final DatabaseService _databaseService = DatabaseService();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
    _tabController.addListener(() {
      setState(() {
        _isRestaurantSelected = _tabController.index == 0;
      });
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailOrIdController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupIdController.dispose();
    _signupFssaiController.dispose();
    _createPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Firebase authentication methods
  Future<void> _loginUser() async {
    setState(() => _isLoading = true);
    try {
      // Get email/ID and password from controllers
      final String emailOrId = _loginEmailOrIdController.text.trim();
      final String password = _loginPasswordController.text;
      
      // For testing - allow "test" to bypass Firebase
      if (emailOrId.contains('test')) {
        await Future.delayed(Duration(seconds: 1));
        setState(() => _isLoading = false);
        // Just close the login form since AuthWrapper will handle navigation
        return;
      }
      
      // Determine if input is email or ID
      bool isEmail = emailOrId.contains('@');
      
      if (isEmail) {
        // Login directly with email using AuthService
        await authService.signInWithEmailAndPassword(
          email: emailOrId,
          password: password,
        );
      } else {
        // If it's an ID, use AuthService's signInWithID method
        await authService.signInWithID(
          emailOrId, 
          password, 
          _isRestaurantSelected
        );
      }
      
      // Successfully logged in, AuthWrapper will handle navigation
      setState(() => _isLoading = false);
      
    } catch (e) {
      setState(() => _isLoading = false);
      String errorMessage = 'Login failed';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No account found with this email or ID.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email format.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled.';
            break;
          default:
            errorMessage = e.message ?? 'An unknown error occurred.';
        }
      } else {
        errorMessage = e.toString();
      }
      
      _showErrorDialog('Login Failed', errorMessage);
    }
  }

  Future<void> _registerUser() async {
    if (_isSignupSecondStep) {
      // Validate passwords match
      if (_createPasswordController.text != _confirmPasswordController.text) {
        setState(() => _passwordsMatch = false);
        return;
      }
      
      setState(() => _isLoading = true);
      
      try {
        // Debug print to verify we're reaching this point
        print('Attempting user registration with email: ${_signupEmailController.text.trim()}');
        
        // Use AuthService instead of direct Firebase calls
        await authService.registerWithEmailAndPassword(
          email: _signupEmailController.text.trim(),
          password: _createPasswordController.text,
          name: _signupNameController.text.trim(),
          regNumber: _signupIdController.text.trim(),
          isRestaurant: _isRestaurantSelected,
        );
        
        print('User registered successfully');
        
        // Successfully registered, AuthWrapper will handle navigation
        setState(() => _isLoading = false);
        
      } catch (e) {
        setState(() => _isLoading = false);
        String errorMessage = 'Registration failed';
        
        if (e is FirebaseAuthException) {
          print('FirebaseAuthException code: ${e.code}');
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'This email is already registered.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
            case 'operation-not-allowed':
              errorMessage = 'Email/password accounts are not enabled in Firebase.';
              break;
            case 'weak-password':
              errorMessage = 'The password is too weak. Use at least 6 characters.';
              break;
            default:
              errorMessage = e.message ?? 'An unknown error occurred.';
          }
        } else {
          errorMessage = e.toString();
        }
        
        print('Registration error: $errorMessage');
        _showErrorDialog('Registration Failed', errorMessage);
      }
    } else {
      // Move to password creation step
      setState(() => _isSignupSecondStep = true);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo or App Name
                        Text(
                          "Food Donation",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          _isLogin ? "Login to your account" : "Create a new account",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // Tab Bar for Restaurant/NGO selection
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.orange,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black54,
                            tabs: [
                              Tab(text: "Restaurant"),
                              Tab(text: "NGO"),
                            ],
                          ),
                        ),
                        SizedBox(height: 25),
                        
                        // Login/Signup Form
                        _isLogin 
                            ? _buildLoginForm() 
                            : (_isSignupSecondStep 
                                ? _buildCreatePasswordForm() 
                                : _buildSignupForm()),
                        
                        SizedBox(height: 16),
                        
                        // Switch between login/signup
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? "Don't have an account? " : "Already have an account? ",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _isSignupSecondStep = false; // Reset to first step when switching
                                });
                              },
                              child: Text(
                                _isLogin ? "Sign up" : "Login",
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginEmailOrIdController,
            decoration: InputDecoration(
              labelText: _isRestaurantSelected 
                  ? 'Email ID or FSSAI No.' 
                  : 'Email ID or Reg No.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.person, color: Colors.orange),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your Email ID or Number';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.lock, color: Colors.orange),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetPassword,
              child: Text('Forgot Password?'),
            ),
          ),
          ElevatedButton(
            onPressed: _isLoading 
                ? null 
                : () {
                    if (_loginFormKey.currentState!.validate()) {
                      _loginUser();
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white) 
                : Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _resetPassword() async {
    final TextEditingController emailController = TextEditingController(text: _loginEmailOrIdController.text);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter your email address to receive a password reset link.'),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await authService.resetPassword(emailController.text);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password reset email sent. Check your inbox.')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to send password reset email: $e')),
                );
              }
            },
            child: Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _signupNameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.person, color: Colors.orange),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _signupEmailController,
            decoration: InputDecoration(
              labelText: 'Email ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.email, color: Colors.orange),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              } else if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _signupIdController,
            decoration: InputDecoration(
              labelText: _isRestaurantSelected ? 'FSSAI No.' : 'Registration No.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.numbers, color: Colors.orange),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your ${_isRestaurantSelected ? 'FSSAI' : 'Registration'} number';
              }
              return null;
            },
          ),
          if (!_isRestaurantSelected) ...[
            SizedBox(height: 16),
            TextFormField(
              controller: _signupFssaiController,
              decoration: InputDecoration(
                labelText: 'FSSAI No. (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(Icons.restaurant, color: Colors.orange),
              ),
            ),
          ],
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_signupFormKey.currentState!.validate()) {
                _registerUser();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'NEXT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePasswordForm() {
    return Form(
      key: _createPasswordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Create a Password",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade800,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _createPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Create Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.lock, color: Colors.orange),
              errorText: _passwordsMatch ? null : 'Passwords do not match',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please create a password';
              } else if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onChanged: (value) {
              // Reset password match status when typing
              if (!_passwordsMatch) {
                setState(() => _passwordsMatch = true);
              }
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: Icon(Icons.lock_outline, color: Colors.orange),
              errorText: _passwordsMatch ? null : 'Passwords do not match',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              return null;
            },
            onChanged: (value) {
              // Reset password match status when typing
              if (!_passwordsMatch) {
                setState(() => _passwordsMatch = true);
              }
            },
          ),
          SizedBox(height: 24),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _isSignupSecondStep = false);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back),
                    SizedBox(width: 4),
                    Text('Back'),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading 
                      ? null 
                      : () {
                          if (_createPasswordFormKey.currentState!.validate()) {
                            _registerUser();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}