
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inherited_widget_demo/counter.dart';
import 'package:inherited_widget_demo/counter_wrapper.dart';
/// 使计数状态改变
class WidgetA extends StatefulWidget {
  const WidgetA({Key? key}) : super(key: key);

  @override
  _WidgetAState createState() => _WidgetAState();
}

class _WidgetAState extends State<WidgetA> {
  @override
  Widget build(BuildContext context) {
    print("A refresh");
    return ElevatedButton(onPressed: onPressed, child: Text("Increment"));
  }
  onPressed() {
    CounterWrapperState wrapper = CounterWrapper.of(context, build: false);
    wrapper.incrementCounter();
  }
}

/// 局部刷新
class WidgetB extends StatelessWidget {
  const WidgetB({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print("widget B 整个 刷新");
    return Builder(builder: (contextTwo) {
      print("widget B Text 局部刷新");
      final CounterWrapperState state =
      CounterWrapper.of(contextTwo, build: true);
      return Text('${state.counter}');
    });
  }
}

/// inheritedWidget刷新时，也刷新
class WidgetC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterWrapperState state =
    CounterWrapper.of(context, build: true);
    print("widget C 刷新");
    return new Text('I am Widget C ${state.counter}');
  }
}
/// inheritedWidget刷新时，不刷新
class WidgetC1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterWrapperState state =
    CounterWrapper.of(context, build: false);
    print("widget C1 刷新");
    return new Text('I am Widget C1 ${state.counter}');
  }
}
/// 不依赖inheriteWidget状态的子部件
class WidgetD extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("widget D 刷新");
    return new Text('I am Widget D');
  }
}

class WidgetE extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final Counter? counter = Counter.of(context);
    return Text("counter value ${counter?.counter}");
  }
}