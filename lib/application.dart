// ignore_for_file: must_be_immutable

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lenra_client/oauth2.dart';
import 'package:lenra_client/socket.dart';
import 'package:oauth2_client/access_token_response.dart';

/// A widget that handles the Lenra OAuth2 authentication flow.
class LenraApplication extends StatelessWidget {
  /// The UI to show after the authentication flow.
  final Widget child;

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
  }) {
    this.oauthRedirectPort =
        oauthRedirectPort ?? (kIsWeb ? Uri.base.port : 10000);
  }

  @override
  Widget build(BuildContext context) {
    LenraOauth2Client oauth2 = LenraOauth2Client(
      baseUri: oauthBaseUri,
      redirectUri: getPlatformRedirectUri(
        androidApplicationId: androidApplicaionId,
        oauthRedirectPort: oauthRedirectPort,
        oauthRedirectPath: oauthRedirectPath,
      ),
      clientId: clientId,
      clientSecret: clientSecret,
      customUriScheme: getPlatformCustomUriScheme(
        androidApplicationId: androidApplicaionId,
        oauthRedirectPort: oauthRedirectPort,
      ),
      scopes: scopes,
    );

    return FutureBuilder(
      future: oauth2.refreshToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error ${snapshot.error}');
          }

          return SocketManager(
            appName: appName,
            endpoint: socketEndpoint,
            token: snapshot.data as AccessTokenResponse,
            child: child,
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
