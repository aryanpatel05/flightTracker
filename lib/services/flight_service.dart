import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight.dart';

class FlightService {
  final String username = 'aryan5'; // Replace with your OpenSky username
  final String password = 'aryan_kumar'; // Replace with your OpenSky password

  Future<List<Flight>> fetchFlights() async {
    final credentials = base64Encode(utf8.encode('$username:$password'));
    final response = await http.get(
      Uri.parse(''), // Your API KEY
      headers: {
        'Authorization': 'Basic $credentials',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      List<Flight> flights = [];
      for (var flightData in jsonData['states']) {
        flights.add(Flight.fromJson(flightData));
      }
      return flights;
    } else if (response.statusCode == 429) {
      print('Rate limit hit, retrying after delay...');
      await Future.delayed(Duration(minutes: 1)); // Retry after 1 minute
      return fetchFlights();
    } else {
      print('Failed to load flight data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to load flight data');
    }
  }
}
