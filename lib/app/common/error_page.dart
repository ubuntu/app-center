import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  final String message;
  final IconData icon;

  const ErrorPage({required this.message, required this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 90,
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
