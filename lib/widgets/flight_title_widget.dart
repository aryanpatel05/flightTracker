import 'package:flutter/material.dart';

class FlightTitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons
              .public, // Earth icon (you can replace it with a custom asset if needed)
          color: Colors.black,
          size: 40.0,
        ),
        SizedBox(width: 10),
        Text(
          'Flight Tracker',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
