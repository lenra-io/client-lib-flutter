import 'package:oauth2_client/access_token_response.dart';
import 'package:phoenix_wings/html.dart';

class LenraApp {
  final String appName;
  late PhoenixSocket socket;

  LenraApp(this.appName, {AccessTokenResponse? token}) {
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
}
