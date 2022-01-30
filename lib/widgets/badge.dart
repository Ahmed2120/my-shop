import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final String value;

  const Badge({required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red
            ),
            constraints: BoxConstraints(minHeight: 20, minWidth: 20),
            child: Text(value, style: TextStyle(fontSize: 10), textAlign: TextAlign.center,),
          ),
        )
      ],
    );
  }
}
