import 'package:flutter/material.dart';

class Bird extends StatefulWidget {
  final double radius;

  const Bird({super.key, this.radius = 100});

  @override
  State<Bird> createState() => _BirdState();
}

class _BirdState extends State<Bird> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.radius,
      width: widget.radius,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.yellow),
    );
  }
}
