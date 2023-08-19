import 'package:flutter/foundation.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

/// A class that represents a Lenra OAuth2 client.
class LenraOauth2Client {
  late OAuth2Helper helper;

  /// Creates the helper usable to refresh the OAuth2 token.
  LenraOauth2Client({
    required String baseUri,
    required String redirectUri,
    required String clientId,
    required String customUriScheme,
    String? clientSecret,
    List<String> scopes = const [],
  }) {
    helper = OAuth2Helper(
      OAuth2Client(
          authorizeUrl: '$baseUri/oauth2/auth',
          tokenUrl: '$baseUri/oauth2/token',
          revokeUrl: '$baseUri/oauth2/revoke',
          redirectUri: redirectUri,
          customUriScheme: customUriScheme),
      grantType: OAuth2Helper.authorizationCode,
      clientId: clientId,
      clientSecret: clientSecret,
      scopes: scopes,
    );
  }

  /// Refreshes the OAuth2 token.
  Future<AccessTokenResponse?> refreshToken() async => await helper.getToken();
}

/// Get the custom uri scheme of the app for the current plateform.
String getPlatformCustomUriScheme({
  String androidApplicationId = "com.example.app",
  int oauthRedirectPort = 10000,
}) {
  // It is important to check for web first because web is also returning the TargetPlatform of the device.
  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      // Apparently the customUriScheme should be the full uri for Windows and Linux for oauth2_client to work properly
      return "http://localhost:$oauthRedirectPort";
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return androidApplicationId;
    }
  }
  return "http";
}

/// Get the custom uri scheme of the app for the current plateform.
String getPlatformRedirectUri({
  String androidApplicationId = "com.example.app",
  int oauthRedirectPort = 10000,
  String oauthRedirectPath = "/redirect.html",
}) {
  // It is important to check for web first because web is also returning the TargetPlatform of the device.
  if (kIsWeb) {
    return "${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}$oauthRedirectPath";
  }
  if (defaultTargetPlatform == TargetPlatform.android) {
    return "$androidApplicationId://";
  }

  return "http://localhost:$oauthRedirectPort$oauthRedirectPath";
}
