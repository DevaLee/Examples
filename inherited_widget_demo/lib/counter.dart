import 'package:flutter/cupertino.dart';

class Counter extends InheritedWidget {
    const Counter( {Key? key,  required this.child, required this.counter})
      : super(key: key, child: child);

  final int counter;

  final Widget child;

  static Counter? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<Counter>();
  }

  @override
  bool updateShouldNotify(covariant Counter oldWidget) {
    return oldWidget.counter != counter;
  }
}