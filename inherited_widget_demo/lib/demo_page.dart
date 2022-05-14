import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inherited_widget_demo/counter.dart';
import 'package:inherited_widget_demo/counter_wrapper.dart';
import 'package:inherited_widget_demo/widgets.dart';

class DemoPage extends StatelessWidget {
  const DemoPage({Key? key}) : super(key: key);

  Widget buildStatefulInheritedWidget(BuildContext context) {
    return CounterWrapper(
        child: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                WidgetB(),
                WidgetA(),
                WidgetC(),
                WidgetC1(),
                WidgetD(),
              ],
            ),
          ),
        ));
  }

  Widget buildInheritedWidget(BuildContext context) {
    return Counter(
        counter: 5,
        child: Scaffold(
          appBar: AppBar(),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                WidgetE(),
              ],
            ),
          ),
        ));

  }

  @override
  Widget build(BuildContext context) {

    return buildStatefulInheritedWidget(context);
  }
}
