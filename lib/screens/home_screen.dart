import 'package:flutter/material.dart';
import 'flight_map_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for the HomeScreen
      body: Center(
        child: GestureDetector(
          onTap: () {
            // Navigate to the Flight Map Screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FlightMapScreen()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Earth Logo (Icon)
              Icon(
                Icons.public, // Earth icon
                size: 40,
                color: Colors.black,
              ),
              SizedBox(width: 10), // Space between the icon and the text
              // "Flight Tracker" Text
              Text(
                'Flight Tracker',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
