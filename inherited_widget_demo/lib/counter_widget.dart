

import 'package:flutter/cupertino.dart';

import 'counter_wrapper.dart';

class CounterWidget extends InheritedWidget {
  const CounterWidget(
      {Key? key,
        required this.counter,
        required this.child,
        required this.data})
      : super(child: child, key: key);

  final int counter;

  final Widget child;

  final CounterWrapperState data;

  /// 获取 CounterWidget 实例
  static CounterWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterWidget>();
  }

  @override
  bool updateShouldNotify(covariant CounterWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return oldWidget.counter != counter;
  }
}