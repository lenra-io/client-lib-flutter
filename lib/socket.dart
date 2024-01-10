import 'package:flutter/widgets.dart';
import 'package:lenra_client/socket_helper_stub.dart'
    if (dart.library.io) 'package:lenra_client/socket_helper_io.dart'
    if (dart.library.js) 'package:lenra_client/socket_helper_web.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

class SocketManager extends StatefulWidget {
  final String? appName;
  final String endpoint;
  final Widget child;
  final AccessTokenResponse token;
  final bool autoConnect;

  const SocketManager({
    Key? key,
    required this.endpoint,
    required this.child,
    required this.token,
    this.appName,
    this.autoConnect = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SocketManagerState();
  }
}

class _SocketManagerState extends State<SocketManager> {
  late PhoenixSocket socket;
  bool connected = false;

  @override
  void initState() {
    super.initState();
    createSocket();
  }

  void createSocket() {
    Map<String, String> params = {
      "token": widget.token.accessToken!,
    };
    if (widget.appName != null) {
      params["app"] = widget.appName!;
    }
    socket = createPhoenixSocket(
      widget.endpoint,
      params,
    );

    socket.onOpen(() {
      print("Socket opened");
      setState(() {
        connected = true;
      });
    });
    socket.onClose((_) {
      print("Socket closed");
      setState(() {
        connected = false;
      });
    });
    socket.onError((error) {
      print("Socket error: $error");
      throw error;
    });
    if (widget.autoConnect) {
      socket.connect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LenraSocket(
      socket: socket,
      child: widget.child,
      connected: connected,
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}

class LenraSocket extends InheritedWidget {
  final PhoenixSocket socket;
  final bool connected;

  const LenraSocket(
      {super.key,
      required super.child,
      required this.socket,
      required this.connected});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    if (oldWidget is! LenraSocket) return true;
    return oldWidget.connected != connected || oldWidget.socket != socket;
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
