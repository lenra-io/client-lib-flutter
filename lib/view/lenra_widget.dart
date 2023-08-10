import 'package:flutter/material.dart';
import 'package:lenra_client/view/lenra_app.dart';
import 'package:lenra_client/view/lenra_route.dart';

class LenraWidget extends StatelessWidget {
  final String route;
  final Widget Function(ListenerCall, Map<String, dynamic>) builder;
  final Widget loader;
  const LenraWidget({
    required this.route,
    required this.builder,
    required this.loader,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LenraRouteWidget(
      app: LenraApp.of(context),
      route: route,
      builder: builder,
      loader: loader,
    );
  }
}

class LenraRouteWidget extends StatefulWidget {
  final LenraApp app;
  final String route;
  final Widget Function(ListenerCall, Map<String, dynamic>) builder;
  final Widget loader;
  LenraRouteWidget({
    super.key,
    required this.app,
    required this.route,
    required this.builder,
    required this.loader,
  });

  @override
  State<StatefulWidget> createState() {
    return LenraRouteWidgetState();
  }
}

class LenraRouteWidgetState extends State<LenraRouteWidget> {
  late LenraRoute lenraRoute;
  Map<String, dynamic>? json;

  @override
  initState() {
    super.initState();
    lenraRoute = LenraRoute(widget.app, widget.route, updateState);
  }

  @override
  Widget build(BuildContext context) {
    if (json == null) {
      return widget.loader;
    }
    return widget.builder(lenraRoute.callListener, json!);
  }

  @override
  void dispose() {
    lenraRoute.close();
    super.dispose();
  }

  void updateState(Map<String, dynamic> newJson) {
    setState(() {
      json = newJson;
    });
  }
}
