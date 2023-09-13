import 'package:flutter/material.dart';

import 'dart:math' as math;

class SpinItem extends StatefulWidget {
  const SpinItem({super.key});

  @override
  State<SpinItem> createState() => _SpinItemState();
}

class _SpinItemState extends State<SpinItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(seconds: 2))
        ..repeat();
  //
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi,
              child: child,
            );
          },
          child: Image.asset(
            'assets/spin.png',
            height: 150,
            width: 150,
          ),
        ),
      ),
    );
  }
}
