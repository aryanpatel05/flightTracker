// ignore_for_file: unused_field

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../services/flight_service.dart';
import '../models/flight.dart';

class FlightMapScreen extends StatefulWidget {
  @override
  _FlightMapScreenState createState() => _FlightMapScreenState();
}

class _FlightMapScreenState extends State<FlightMapScreen> {
  List<Flight> _flights = [];
  List<Marker> _flightMarkers = [];
  bool _loading = true;
  bool _locationLoading = true;
  bool _permissionGranted = false;
  Timer? _timer;
  LatLng? _userLocation;
  double _currentZoom = 8.0; // Initial zoom level
  String _searchQuery = '';
  MapController _mapController = MapController();

  Flight? _searchedFlight; // Track the searched flight

  @override
  void initState() {
    super.initState();
    _checkAndRequestLocationPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Check and request location permission using Geolocator
  Future<void> _checkAndRequestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // If permission is permanently denied, open app settings
      await ph.openAppSettings();
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      setState(() {
        _permissionGranted = true;
      });
      _getUserLocation();
      _loadFlightData();
      _startAutoRefresh();
    } else {
      // Handle permission denied case
      _showPermissionDeniedMessage();
    }
  }

  // Get the user's current location using Geolocator
  Future<void> _getUserLocation() async {
    try {
      setState(() {
        _locationLoading = true;
      });

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
        _locationLoading = false;
      });

      // Move the map to the user's location
      Future.delayed(Duration(milliseconds: 500), () {
        _mapController.move(_userLocation!, 15.0);
      });
    } catch (e) {
      print('Error getting user location: $e');
      setState(() {
        _locationLoading = false;
        _userLocation = null;
      });
    }
  }

  // Start auto-refreshing the flight data
  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(minutes: 30), (timer) {
      _loadFlightData();
    });
  }

  // Load flight data from the service
  void _loadFlightData() async {
    FlightService flightService = FlightService();
    try {
      List<Flight> flights = await flightService.fetchFlights();
      setState(() {
        _flights = flights;
        _updateMarkers();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      print('Error fetching flight data: $e');
    }
  }

  // Update flight markers on the map
  void _updateMarkers() {
    _flightMarkers = _flights.map((flight) {
      // Check if this is the searched flight
      bool isSearchedFlight = _searchedFlight != null &&
          flight.flightNumber == _searchedFlight!.flightNumber;

      return Marker(
        point: LatLng(flight.latitude, flight.longitude),
        builder: (ctx) => GestureDetector(
          onTap: () => _showFlightDetails(ctx, flight),
          child: Transform.rotate(
            angle:
                flight.heading * (3.14159 / 180), // Convert degrees to radians
            child: Icon(
              Icons.airplanemode_active,
              color: isSearchedFlight
                  ? Colors.yellow
                  : (flight.onGround
                      ? Colors.blue
                      : Colors.red), // Yellow if searched
              size: isSearchedFlight
                  ? 30
                  : 20, // Larger size for the searched flight
            ),
          ),
        ),
        width: isSearchedFlight
            ? 60
            : 40, // Increase width if it's the searched flight
        height: isSearchedFlight
            ? 60
            : 40, // Increase height if it's the searched flight
      );
    }).toList();
  }

  // Show flight details in a dialog
  void _showFlightDetails(BuildContext context, Flight flight) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(flight.flightNumber.isNotEmpty
              ? flight.flightNumber
              : 'Unknown Flight'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ICAO24: ${flight.icao24}'),
                Text('Country: ${flight.originCountry}'),
                Text(
                    'Last Position Update: ${DateTime.fromMillisecondsSinceEpoch(flight.timePosition * 1000)}'),
                Text(
                    'Last Contact: ${DateTime.fromMillisecondsSinceEpoch(flight.lastContact * 1000)}'),
                Text('Latitude: ${flight.latitude}'),
                Text('Longitude: ${flight.longitude}'),
                Text('Barometric Altitude: ${flight.altitude} m'),
                Text('Geometric Altitude: ${flight.geoAltitude} m'),
                Text('On Ground: ${flight.onGround ? 'Yes' : 'No'}'),
                Text('Velocity: ${flight.speed} m/s'),
                Text('Heading: ${flight.heading}°'),
                Text('Vertical Rate: ${flight.verticalRate} m/s'),
                Text('Squawk: ${flight.squawk}'),
                Text('SPI: ${flight.spi ? 'Yes' : 'No'}'),
                Text(
                    'Position Source: ${_getPositionSource(flight.positionSource)}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Handle search functionality
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _searchFlight(query);
  }

  // Highlight the searched flight
  void _searchFlight(String query) {
    final flight = _flights.firstWhere(
        (flight) => flight.flightNumber.toLowerCase() == query.toLowerCase(),
        orElse: () => Flight(
              icao24: 'Unknown',
              flightNumber: 'Unknown',
              originCountry: 'Unknown',
              timePosition: 0,
              lastContact: 0,
              longitude: 0.0,
              latitude: 0.0,
              altitude: 0.0,
              onGround: true,
              speed: 0.0,
              heading: 0.0,
              verticalRate: 0.0,
              geoAltitude: 0.0,
              squawk: 'N/A',
              spi: false,
              positionSource: 0,
            ));

    setState(() {
      _searchedFlight = flight; // Store the searched flight
    });

    // Zoom in further and move the map to the searched flight's location
    _mapController.move(LatLng(flight.latitude, flight.longitude), 15.0);
  }

  String _getPositionSource(int positionSource) {
    switch (positionSource) {
      case 0:
        return 'ADS-B';
      case 1:
        return 'ASTERIX';
      case 2:
        return 'MLAT';
      default:
        return 'Unknown';
    }
  }

  // Zoom in on the map
  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  // Zoom out on the map
  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
      _mapController.move(_mapController.center, _currentZoom);
    });
  }

  // Show a message if permission is denied
  void _showPermissionDeniedMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Denied'),
          content: Text(
              'Location permission is required to show flights near you. Please enable it from settings.'),
          actions: <Widget>[
            TextButton(
              child: Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                ph.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flight Tracker'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by flight number...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: _permissionGranted
          ? _locationLoading
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _userLocation,
                        zoom: _currentZoom,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: _flightMarkers +
                              [
                                if (_userLocation != null)
                                  Marker(
                                    point: _userLocation!,
                                    builder: (ctx) => const Icon(
                                      Icons.location_pin,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                    width: 40,
                                    height: 40,
                                  ),
                              ],
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        children: [
                          FloatingActionButton(
                            mini: true,
                            onPressed: _zoomIn,
                            child: Icon(Icons.add),
                          ),
                          SizedBox(height: 10),
                          FloatingActionButton(
                            mini: true,
                            onPressed: _zoomOut,
                            child: Icon(Icons.remove),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
          : Center(
              child:
                  Text('Location permission is required to display the map.'),
            ),
    );
  }
}
