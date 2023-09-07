import 'package:flutter/widgets.dart';
import 'package:lenra_client/socket_helper_stub.dart'
    if (dart.library.io) 'package:lenra_client/socket_helper_io.dart'
    if (dart.library.js) 'package:lenra_client/socket_helper_web.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

class SocketManager extends StatefulWidget {
  final String appName;
  final String endpoint;
  final Widget child;
  final AccessTokenResponse token;

  const SocketManager({
    Key? key,
    required this.appName,
    required this.endpoint,
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
    createSocket();
  }

  void createSocket() {
    Map<String, String> params = {
      "app": widget.appName,
      "token": widget.token.accessToken!,
    };
    socket = createPhoenixSocket(
      widget.endpoint,
      params,
    );

    socket.onError((error) => throw error);
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
