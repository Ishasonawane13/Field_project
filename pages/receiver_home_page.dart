import 'package:flutter/material.dart';
import 'profile_page.dart';

class ReceiverHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NGO Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Incoming Donations',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800]),
            ),
            SizedBox(height: 10),
            _buildIncomingDonations(),
            SizedBox(height: 20),
            Text(
              'Donation History',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800]),
            ),
            SizedBox(height: 10),
            _buildDonationHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomingDonations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Restaurant X',
                  style: TextStyle(color: Colors.orange[800])),
              subtitle: Text('Tomorrow, 3:00 PM'),
              trailing: Icon(Icons.food_bank, color: Colors.orange),
            ),
            Divider(),
            ListTile(
              title: Text('Restaurant Y',
                  style: TextStyle(color: Colors.orange[800])),
              subtitle: Text('Day after tomorrow, 1:00 PM'),
              trailing: Icon(Icons.food_bank, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Restaurant Z',
                  style: TextStyle(color: Colors.orange[800])),
              subtitle: Text('Donated on 2023-10-26'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
            Divider(),
            ListTile(
              title: Text('Restaurant W',
                  style: TextStyle(color: Colors.orange[800])),
              subtitle: Text('Donated on 2023-10-20'),
              trailing: Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}