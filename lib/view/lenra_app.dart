import 'package:flutter/widgets.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:phoenix_wings/html.dart';

class LenraApp extends InheritedWidget {
  final String appName;
  late PhoenixSocket socket;

  LenraApp(this.appName,
      {super.key, AccessTokenResponse? token, required super.child}) {
    Map<String, String> params = {
      "app": appName,
      "token": token!.accessToken!,
    };

    socket = PhoenixSocket(
      "ws://localhost:4001/socket/websocket",
      connectionProvider: PhoenixHtmlConnection.provider,
      socketOptions: PhoenixSocketOptions(params: params),
    );

    socket.connect();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }

  static LenraApp? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LenraApp>();
  }

  static LenraApp of(BuildContext context) {
    final LenraApp? result = maybeOf(context);
    assert(result != null, 'No LenraApp found in context');
    return result!;
  }
}
