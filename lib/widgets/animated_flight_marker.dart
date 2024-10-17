import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

class AnimatedFlightMarker {
  LatLng initialPosition;
  LatLng destination;
  double heading;
  final AnimationController controller;
  final VoidCallback onTap;

  AnimatedFlightMarker({
    required this.initialPosition,
    required this.destination,
    required this.heading,
    required TickerProvider vsync,
    required this.onTap,
  }) : controller = AnimationController(
          duration: const Duration(seconds: 30),
          vsync: vsync,
        ) {
    controller.forward();
  }

  Marker buildMarker() {
    final animation = Tween<LatLng>(
      begin: initialPosition,
      end: destination,
    ).animate(controller);

    return Marker(
      point: animation.value,
      builder: (ctx) => Transform.rotate(
        angle: heading * pi / 180,
        child: GestureDetector(
          onTap: onTap,
          child: Icon(
            Icons.airplanemode_active,
            color: Colors.red,
            size: 20,
          ),
        ),
      ),
    );
  }

  void dispose() {
    controller.dispose();
  }
}
