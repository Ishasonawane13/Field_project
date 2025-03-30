import 'package:flutter/material.dart';
import 'donor_home_page.dart';
import 'receiver_home_page.dart';

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isRestaurant = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _isRestaurant,
                    onChanged: (value) {
                      setState(() {
                        _isRestaurant = value!;
                      });
                    },
                  ),
                  Text('Restaurant'),
                  Radio<bool>(
                    value: false,
                    groupValue: _isRestaurant,
                    onChanged: (value) {
                      setState(() {
                        _isRestaurant = value!;
                      });
                    },
                  ),
                  Text('NGO'),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_isRestaurant) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DonorHomePage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReceiverHomePage()),
                      );
                    }
                  }
                },
                child: Text(_isLogin ? 'Login' : 'Signup'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin ? 'Create an account' : 'Already have an account?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}