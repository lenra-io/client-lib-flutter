import 'package:lenra/view/lenra_app.dart';
import 'package:json_patch/json_patch.dart';
import 'package:phoenix_wings/html.dart';

typedef ListenerCall = Function(Map<String, dynamic>);

class LenraRoute {
  Map<String, dynamic>? json;
  String route;
  void Function(Map<String, dynamic>) onChange;
  late PhoenixChannel channel;

  LenraRoute(LenraApp lenraApp, this.route, this.onChange) {
    channel = lenraApp.socket.channel("route:$route", {"mode": "json"});

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
