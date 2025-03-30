import 'package:flutter/material.dart';
import 'profile_page.dart';

class DonorHomePage extends StatefulWidget {
  @override
  _DonorHomePageState createState() => _DonorHomePageState();
}

class _DonorHomePageState extends State<DonorHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Restaurant Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
          ],
        ),
        // ... (DonorHomePage body and bottomNavigationBar)
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scheduled Donations to NGOs',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800]),
                ),
                SizedBox(height: 10),
                _buildScheduledDonations(),
                SizedBox(height: 20),
                Text(
                  'Available NGOs',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800]),
                ),
                SizedBox(height: 10),
                _buildAvailableNgos(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.orange),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, color: Colors.orange),
              label: 'Donate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history, color: Colors.orange),
              label: 'History',
            ),
          ],
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
        )
    );
  }
  // ... (DonorHomePage helper functions)
  Widget _buildScheduledDonations() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text('NGO A', style: TextStyle(color: Colors.orange[800])),
              subtitle: Text('Tomorrow, 12:00 PM'),
              trailing: Icon(Icons.calendar_today, color: Colors.orange),
            ),
            Divider(),
            ListTile(
              title: Text('NGO B', style: TextStyle(color: Colors.orange[800])),
              subtitle: Text('Day after tomorrow, 1:00 PM'),
              trailing: Icon(Icons.calendar_today, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableNgos() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: Text('NGO C (Nearby)',
                  style: TextStyle(color: Colors.orange[800])),
              subtitle: Text('Distance: 1 km'),
              trailing: ElevatedButton(
                  onPressed: () {}, child: Text("Donate")),
            ),
            Divider(),
            ListTile(
              title: Text('NGO D (Recent)',
                  style: TextStyle(color: Colors.orange[800])),
              subtitle: Text('Donated 2 days ago'),
              trailing: ElevatedButton(
                  onPressed: () {}, child: Text("Donate")),
            ),
          ],
        ),
      ),
    );
  }
}