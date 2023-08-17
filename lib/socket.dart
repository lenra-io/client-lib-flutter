import 'package:flutter/widgets.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:phoenix_wings/html.dart';

class SocketManager extends StatefulWidget {
  final String appName;
  final Widget child;
  final AccessTokenResponse token;

  const SocketManager({
    Key? key,
    required this.appName,
    required this.child,
    required this.token,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SocketManagerState();
  }
}

class _SocketManagerState extends State<SocketManager> {
  late PhoenixSocket socket;

  @override
  void initState() {
    super.initState();
    openSocket();
  }

  void openSocket() {
    Map<String, String> params = {
      "app": widget.appName,
      "token": widget.token.accessToken!,
    };
    socket = PhoenixSocket(
      "ws://localhost:4001/socket/websocket",
      connectionProvider: PhoenixHtmlConnection.provider,
      socketOptions: PhoenixSocketOptions(params: params),
    );

    socket.connect();
  }

  @override
  Widget build(BuildContext context) {
    return LenraSocket(
      socket: socket,
      child: widget.child,
    );
  }
}

class LenraSocket extends InheritedWidget {
  final PhoenixSocket socket;

  const LenraSocket({super.key, required super.child, required this.socket});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    if (oldWidget is! LenraSocket) return true;
    return oldWidget.socket != socket;
  }

  static LenraSocket? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LenraSocket>();
  }

  static LenraSocket of(BuildContext context) {
    final LenraSocket? result = maybeOf(context);
    assert(result != null, 'No LenraApp found in context');
    return result!;
  }
}
