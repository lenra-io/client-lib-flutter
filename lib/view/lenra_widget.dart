import 'package:lenra/view/lenra_app.dart';
import 'package:lenra/view/lenra_route.dart';
import 'package:lenra/model/token_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LenraWidget extends StatefulWidget {
  final String route;
  final Widget Function(ListenerCall, Map<String, dynamic>) builder;
  final Widget loader;
  const LenraWidget(
      {required this.route, required this.builder, required this.loader});

  @override
  State<StatefulWidget> createState() {
    return LenraWidgetState();
  }
}

class LenraWidgetState extends State<LenraWidget> {
  late LenraRoute lenraRoute;
  Map<String, dynamic>? json;

  @override
  initState() {
    super.initState();
    lenraRoute = LenraRoute(
        LenraApp("test", token: context.read<TokenProvider>().token),
        widget.route,
        updateState);
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
