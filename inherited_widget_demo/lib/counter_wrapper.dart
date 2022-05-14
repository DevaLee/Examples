import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'counter_widget.dart';


class CounterWrapper extends StatefulWidget {
  final Widget child;
  const CounterWrapper({Key? key, required this.child}) : super(key: key);

  static CounterWrapperState of(BuildContext context, {bool build = true}) {
    return build
        ? (context.dependOnInheritedWidgetOfExactType<CounterWidget>())!.data
        : context.findAncestorWidgetOfExactType<CounterWidget>()!.data;
  }

  @override
  CounterWrapperState createState() => CounterWrapperState();
}

class CounterWrapperState extends State<CounterWrapper> {
  int counter = 0;
  void incrementCounter() {
    setState(() {
      counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CounterWidget(data: this, counter: counter, child: widget.child);
  }
}