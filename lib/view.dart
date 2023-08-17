import 'package:flutter/material.dart';
import 'package:lenra_client/socket.dart';
import 'package:lenra_client/route.dart';

typedef ListenerCaller = Function(Map<String, dynamic>);
typedef LenraViewBuilder = Widget Function(
    BuildContext, Map<String, dynamic>, ListenerCaller);

class LenraView extends StatelessWidget {
  final String route;
  final LenraViewBuilder builder;
  final Widget loader;
  const LenraView({
    required this.route,
    required this.builder,
    required this.loader,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LenraRouteWidget(
      socket: LenraSocket.of(context),
      route: route,
      builder: builder,
      loader: loader,
    );
  }
}

class LenraRouteWidget extends StatefulWidget {
  final LenraSocket socket;
  final String route;
  final LenraViewBuilder builder;
  final Widget loader;
  const LenraRouteWidget({
    super.key,
    required this.socket,
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
    lenraRoute = LenraRoute(widget.socket, widget.route, updateState);
  }

  @override
  Widget build(BuildContext context) {
    if (json == null) {
      return widget.loader;
    }
    return widget.builder(context, json!, lenraRoute.callListener);
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
