// ignore_for_file: must_be_immutable

import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lenra_client/oauth2.dart';
import 'package:lenra_client/socket.dart';
import 'package:oauth2_client/access_token_response.dart';

const defaultLoader = Center(child: CircularProgressIndicator());

typedef LoginWidgetBuilder = Widget Function(
    BuildContext, VoidCallback, Object?);

/// A widget that handles the Lenra OAuth2 authentication flow.
class LenraApplication extends StatefulWidget {
  /// The UI to show after the authentication flow.
  final Widget child;

  /// The UI to show during the authentication flow.
  final Widget? loader;

  /// The UI to show before the authentication flow.
  final LoginWidgetBuilder? loginWidgetBuilder;

  /// The lenra instance's OAuth base URI.
  /// Defaults to `http://localhost:4444` in debug mode and `https://auth.lenra.io` in release mode.
  final String oauthBaseUri;

  /// The OAuth2 redirect file path.
  /// Defaults to `/redirect.html`.
  final String oauthRedirectPath;

  /// The OAuth2 redirect port.
  /// Defaults to `Uri.base.port` in web platform and `10000` in other platforms.
  late int oauthRedirectPort;

  /// The name of the application.
  final String? appName;

  /// The OAuth2 client ID.
  final String clientId;

  /// The OAuth2 client secret.
  /// This is not secret in the context of a mobile app.
  /// It is only used to identify the app.
  final String? clientSecret;

  /// The Android application id.
  /// Not needed if you don't create an Android app.
  late String applicationId;

  /// The OAuth2 scopes.
  /// Defaults to `["app:websocket"]`
  final List<String> scopes;

  /// The socket endpoint.
  /// Defaults to `ws://localhost:4001/socket/websocket` in debug mode and `https://api.lenra.io/socket/websocket` in release mode.
  final String socketEndpoint;

  /// The OAuth2 helper for customizing OAuth configuration.
  final LenraOauth2Helper? oauth2helper;

  /// Once logged in auto connect the socket.
  final bool autoConnect;

  /// Creates a new instance of [LenraOauth2Widget].
  LenraApplication({
    super.key,
    required this.clientId,
    required this.child,
    this.appName,
    String? applicationId,
    @Deprecated("Use 'applicationId' instead.") String? androidapplicationId,
    this.socketEndpoint = kDebugMode
        ? "ws://localhost:4001/socket/websocket"
        : "wss://api.lenra.io/socket/websocket",
    this.oauthBaseUri =
        kDebugMode ? "http://localhost:4444" : "https://auth.lenra.io",
    this.oauthRedirectPath = "/redirect.html",
    int? oauthRedirectPort,
    this.scopes = const ["app:websocket"],
    this.clientSecret,
    this.loader,
    this.loginWidgetBuilder,
    this.oauth2helper,
    this.autoConnect = false,
  }) {
    this.oauthRedirectPort =
        oauthRedirectPort ?? (kIsWeb ? Uri.base.port : 10000);
    this.applicationId =
        applicationId ?? androidapplicationId ?? defaultApplicationId;
  }

  @override
  State<LenraApplication> createState() => _LenraApplicationState();
}

class _LenraApplicationState extends State<LenraApplication> {
  late LenraOauth2Controller oauth2Controller;

  @override
  void initState() {
    super.initState();
    var oauth2 = widget.oauth2helper ??
        LenraOauth2Helper(
          baseUri: widget.oauthBaseUri,
          redirectUri: getPlatformRedirectUri(
            applicationId: widget.applicationId,
            oauthRedirectPort: widget.oauthRedirectPort,
            oauthRedirectPath: widget.oauthRedirectPath,
          ),
          clientId: widget.clientId,
          clientSecret: widget.clientSecret,
          customUriScheme: getPlatformCustomUriScheme(
            applicationId: widget.applicationId,
            oauthRedirectPort: widget.oauthRedirectPort,
          ),
          scopes: widget.scopes,
        );
    oauth2Controller = LenraOauth2Controller(oauth2);
    oauth2Controller.addListener(() {
      setState(() {});
    });
    if (widget.loginWidgetBuilder == null) {
      oauth2Controller.login();
    } else {
      oauth2Controller.checkAuthentication();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (oauth2Controller.status == LoginStatus.loggedIn) {
      return LenraApp(
        oauth2Controller: oauth2Controller,
        child: LenraOauth2(
          helper: oauth2Controller.helper,
          child: SocketManager(
            appName: widget.appName,
            endpoint: widget.socketEndpoint,
            token: oauth2Controller.token as AccessTokenResponse,
            autoConnect: widget.autoConnect,
            child: widget.child,
          ),
        ),
      );
    } else if (oauth2Controller.status == LoginStatus.loggedOut) {
      return widget.loginWidgetBuilder!(
        context,
        oauth2Controller.login,
        oauth2Controller.error,
      );
    }
    return widget.loader ?? defaultLoader;
  }
}

class LenraApp extends InheritedWidget {
  final LenraOauth2Controller oauth2Controller;

  const LenraApp(
      {super.key, required super.child, required this.oauth2Controller});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    if (oldWidget is! LenraApp) return true;
    return oldWidget.oauth2Controller != oauth2Controller;
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
