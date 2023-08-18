import 'package:flutter/material.dart';
import 'package:lenra_client/oauth2.dart';
import 'package:lenra_client/socket.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:flutter/foundation.dart';

/// A widget that handles the Lenra OAuth2 authentication flow.
class LenraApplication extends StatelessWidget {
  /// The UI to show after the authentication flow.
  final Widget child;

  /// The lenra instance's hostname and port.
  final String host;

  /// The OAuth2 redirect URL.
  final String oauthRedirectUri;

  /// The name of the application.
  final String appName;

  /// The OAuth2 client ID.
  final String clientId;

  /// The OAuth2 client secret.
  /// This is not secret in the context of a mobile app.
  /// It is only used to identify the app.
  final String? clientSecret;

  /// The OAuth2 custom URI scheme.
  /// This is specific to the platform.
  /// Use getPlatformCustomUriScheme to get the correct value.
  final String customUriScheme;

  /// The OAuth2 scopes.
  /// Defaults to `["app:websocket"]`
  final List<String> scopes;

  /// Creates a new instance of [LenraOauth2Widget].
  const LenraApplication(
      {Key? key,
      required this.child,
      required this.host,
      required this.oauthRedirectUri,
      required this.appName,
      required this.clientId,
      required this.customUriScheme,
      this.clientSecret,
      this.scopes = const ["app:websocket"]})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LenraOauth2Client oauth2 = LenraOauth2Client(
      host: host,
      redirectUri: oauthRedirectUri,
      clientId: clientId,
      clientSecret: clientSecret,
      customUriScheme: customUriScheme,
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

/// Get the custom uri scheme of the app for the current plateform.
String getPlatformCustomUriScheme({
  String androidApplicationId = "com.example.app",
}) {
  // It is important to check for web first because web is also returning the TargetPlatform of the device.
  if (kIsWeb) {
    return "http";
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux) {
    // Apparently the customUriScheme should be the full uri for Windows and Linux for oauth2_client to work properly
    return const String.fromEnvironment("OAUTH_REDIRECT_BASE_URL",
        defaultValue: "http://localhost:10000");
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return androidApplicationId;
  } else {
    return "http";
  }
}
