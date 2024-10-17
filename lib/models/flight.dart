class Flight {
  final String icao24;
  final String flightNumber;
  final String originCountry;
  final int timePosition;
  final int lastContact;
  final double longitude;
  final double latitude;
  final double altitude;
  final bool onGround;
  final double speed;
  final double heading;
  final double verticalRate;
  final double geoAltitude;
  final String squawk;
  final bool spi;
  final int positionSource;

  Flight({
    required this.icao24,
    required this.flightNumber,
    required this.originCountry,
    required this.timePosition,
    required this.lastContact,
    required this.longitude,
    required this.latitude,
    required this.altitude,
    required this.onGround,
    required this.speed,
    required this.heading,
    required this.verticalRate,
    required this.geoAltitude,
    required this.squawk,
    required this.spi,
    required this.positionSource,
  });

  factory Flight.fromJson(List<dynamic> json) {
    return Flight(
      icao24: json[0] ?? 'Unknown', // ICAO24
      flightNumber: json[1] != null ? json[1].trim() : 'Unknown', // Callsign
      originCountry: json[2] ?? 'Unknown', // Origin Country
      timePosition:
          json[3] != null ? json[3] : 0, // Time of last position update
      lastContact: json[4] != null ? json[4] : 0, // Time of last contact
      longitude: json[5] != null ? json[5].toDouble() : 0.0, // Longitude
      latitude: json[6] != null ? json[6].toDouble() : 0.0, // Latitude
      altitude:
          json[7] != null ? json[7].toDouble() : 0.0, // Barometric Altitude
      onGround: json[8] ?? true, // On-ground status
      speed: json[9] != null ? json[9].toDouble() : 0.0, // Velocity
      heading: json[10] != null ? json[10].toDouble() : 0.0, // Heading
      verticalRate:
          json[11] != null ? json[11].toDouble() : 0.0, // Vertical Rate
      geoAltitude:
          json[13] != null ? json[13].toDouble() : 0.0, // Geometric Altitude
      squawk: json[14] != null ? json[14] : 'N/A', // Squawk code
      spi: json[15] ?? false, // SPI indicator
      positionSource: json[16] != null ? json[16] : 0, // Position source
    );
  }
}
