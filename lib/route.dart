import 'dart:async';

import 'package:lenra_client/socket.dart';
import 'package:json_patch/json_patch.dart';
import 'package:logging/logging.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

class LenraRoute {
  static final log = Logger('LenraRoute');

  LenraSocket lenraSocket;
  Map<String, dynamic>? json;
  String route;
  void Function(Map<String, dynamic>) onChange;
  late PhoenixChannel channel;

  LenraRoute(this.lenraSocket, this.route, this.onChange) {
    _openRouteChannel();
  }

  void _openRouteChannel() async {
    if (!lenraSocket.socket.isConnected) {
      await lenraSocket.socket.connect();
    }
    log.info("Join channel $route with app $lenraSocket");
    channel = lenraSocket.socket.channel("route:$route", {"mode": "json"});

    channel.on("ui", (data, ref, joinRef) {
      json = (data as Map<String, dynamic>);
      log.fine("Get new UI on route $route. Ui : ${json.toString()}");
      onChange(json!);
    });

    channel.on("patchUi", (payload, ref, joinRef) {
      Iterable<Map<String, dynamic>> patches =
          (payload?["patch"] as Iterable).map((e) => e as Map<String, dynamic>);
      json = JsonPatch.apply(json, patches, strict: false);
      log.fine("Get new patch on route $route. New ui : ${json.toString()}");

      onChange(json!);
    });

    channel
        .join()
        ?.receive("ok", (response) => log.info("Joined route $route !"))
        .receive("error", (response) => log.info("Unable to join $route"));
  }

  Future<void> callListener(Map<String, dynamic> action) {
    var completer = Completer<void>();

    channel
        .push(event: "run", payload: action)
        ?.receive("ok", (response) => completer.complete())
        .receive(
          "error",
          (response) => completer
              .completeError("An error occured while calling the listener"),
        );

    return completer.future;
  }

  void close() {
    log.info("Leave channel $route");
    channel.leave();
  }
}
