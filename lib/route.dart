import 'package:lenra_client/socket.dart';
import 'package:json_patch/json_patch.dart';
import 'package:phoenix_wings/html.dart';

class LenraRoute {
  Map<String, dynamic>? json;
  String route;
  void Function(Map<String, dynamic>) onChange;
  late PhoenixChannel channel;

  LenraRoute(LenraSocket lenraSocket, this.route, this.onChange) {
    print("Join channel $route with app $lenraSocket");
    channel = lenraSocket.socket.channel("route:$route", {"mode": "json"});

    channel.on("ui", (data, ref, joinRef) {
      json = (data as Map<String, dynamic>);
      print("Get new UI on route $route. Ui : ${json.toString()}");
      onChange(json!);
    });

    channel.on("patchUi", (payload, ref, joinRef) {
      Iterable<Map<String, dynamic>> patches =
          (payload?["patch"] as Iterable).map((e) => e as Map<String, dynamic>);
      json = JsonPatch.apply(json, patches, strict: false);
      print("Get new patch on route $route. New ui : ${json.toString()}");

      onChange(json!);
    });

    channel
        .join()
        ?.receive("ok", (response) => print("Joined route $route !"))
        .receive("error", (response) => print("Unable to join $route"));
  }

  void callListener(Map<String, dynamic> action) {
    channel.push(event: "run", payload: action);
  }

  void close() {
    print("Leave channel $route");
    channel.leave();
  }
}
