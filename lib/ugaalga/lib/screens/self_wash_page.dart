import 'dart:async';
import 'package:flutter/material.dart';

class SelfWashPage extends StatefulWidget {
  @override
  State<SelfWashPage> createState() => _SelfWashPageState();
}

class _SelfWashPageState extends State<SelfWashPage> {
  int seconds = 0;
  Timer? timer;

  void start() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() => seconds++);
    });
  }

  void stop() {
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Self Wash")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Time: $seconds sec"),
          ElevatedButton(onPressed: start, child: Text("Start")),
          ElevatedButton(onPressed: stop, child: Text("Stop")),
        ],
      ),
    );
  }
}
