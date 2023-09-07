// ignore_for_file: must_be_immutable

import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lenra_client/oauth2.dart';
import 'package:lenra_client/socket.dart';
import 'package:oauth2_client/access_token_response.dart';

const defaultLoader = Center(child: CircularProgressIndicator());

typedef LoginWidgetBuilder = Widget Function(BuildContext, VoidCallback);

/// A widget that handles the Lenra OAuth2 authentication flow.
class LenraApplication extends StatefulWidget {
  /// The UI to show after the authentication flow.
  final Widget child;

  /// The UI to show during the authentication flow.
  final Widget? loader;

  /// The UI to show after the authentication flow.
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
  final String appName;

  /// The OAuth2 client ID.
  final String clientId;

  /// The OAuth2 client secret.
  /// This is not secret in the context of a mobile app.
  /// It is only used to identify the app.
  final String? clientSecret;

  /// The Android application id.
  /// Not needed if you don't create an Android app.
  final String androidApplicaionId;

  /// The OAuth2 scopes.
  /// Defaults to `["app:websocket"]`
  final List<String> scopes;

  /// The socket endpoint.
  /// Defaults to `ws://localhost:4001/socket/websocket` in debug mode and `https://api.lenra.io/socket/websocket` in release mode.
  final String socketEndpoint;

  /// Creates a new instance of [LenraOauth2Widget].
  LenraApplication({
    super.key,
    required this.appName,
    required this.clientId,
    required this.child,
    this.androidApplicaionId = 'com.example.client',
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
  }) {
    this.oauthRedirectPort =
        oauthRedirectPort ?? (kIsWeb ? Uri.base.port : 10000);
  }

  @override
  State<LenraApplication> createState() => _LenraApplicationState();
}

class _LenraApplicationState extends State<LenraApplication> {
  late LenraOauth2Helper oauth2;
  bool isLogging = false;

  @override
  void initState() {
    super.initState();
    oauth2 = LenraOauth2Helper(
      baseUri: widget.oauthBaseUri,
      redirectUri: getPlatformRedirectUri(
        androidApplicationId: widget.androidApplicaionId,
        oauthRedirectPort: widget.oauthRedirectPort,
        oauthRedirectPath: widget.oauthRedirectPath,
      ),
      clientId: widget.clientId,
      clientSecret: widget.clientSecret,
      customUriScheme: getPlatformCustomUriScheme(
        androidApplicationId: widget.androidApplicaionId,
        oauthRedirectPort: widget.oauthRedirectPort,
      ),
      scopes: widget.scopes,
    );
    if (widget.loginWidgetBuilder == null) {
      isLogging = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLogging) {
      return LenraOauth2(
        helper: oauth2,
        child: FutureBuilder(
          future: oauth2.getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error ${snapshot.error}');
              }

              return SocketManager(
                appName: widget.appName,
                endpoint: widget.socketEndpoint,
                token: snapshot.data as AccessTokenResponse,
                child: widget.child,
              );
            } else {
              return widget.loader ?? defaultLoader;
            }
          },
        ),
      );
    } else {
      return widget.loginWidgetBuilder!(context, () {
        setState(() {
          isLogging = true;
        });
      });
    }
  }
}
