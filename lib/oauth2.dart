import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

/// A class that represents a Lenra OAuth2 client.
class LenraOauth2Helper extends OAuth2Helper {
  /// Creates the helper usable to refresh the OAuth2 token.
  LenraOauth2Helper({
    required String baseUri,
    required String redirectUri,
    required String clientId,
    required String customUriScheme,
    String? clientSecret,
    List<String> scopes = const [],
  }) : super(
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

  Future<bool> isAuthenticated() async {
    AccessTokenResponse? tknResp = await getTokenFromStorage();

    if (tknResp != null) {
      if (tknResp.refreshNeeded()) {
        //The access token is expired
        if (tknResp.hasRefreshToken()) {
          tknResp = await refreshToken(tknResp);
        } else {
          //No refresh token, fetch a new token
          return false;
        }
      }
      return tknResp.isValid();
    }
    return false;
  }
}

const defaultApplicationId = "com.example.app";

/// Get the custom uri scheme of the app for the current platform.
String getPlatformCustomUriScheme({
  @Deprecated("Use 'applicationId' instead.") String? androidApplicationId,
  String? applicationId,
  int oauthRedirectPort = 10000,
}) {
  // It is important to check for web first because web is also returning the TargetPlatform of the device.
  if (!kIsWeb) {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      // Apparently the customUriScheme should be the full uri for Windows and Linux for oauth2_client to work properly
      return "http://localhost:$oauthRedirectPort";
    } else if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      return applicationId ?? androidApplicationId ?? defaultApplicationId;
    }
  }
  return "http";
}

/// Get the custom uri scheme of the app for the current platform.
String getPlatformRedirectUri({
  @Deprecated("Use 'applicationId' instead") String? androidApplicationId,
  String? applicationId,
  int oauthRedirectPort = 10000,
  String oauthRedirectPath = "/redirect.html",
}) {
  // It is important to check for web first because web is also returning the TargetPlatform of the device.
  if (kIsWeb) {
    return "${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}$oauthRedirectPath";
  }
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    applicationId ??= androidApplicationId ?? defaultApplicationId;
    return "$applicationId://";
  }

  return "http://localhost:$oauthRedirectPort$oauthRedirectPath";
}

class LenraOauth2 extends InheritedWidget {
  final LenraOauth2Helper helper;

  const LenraOauth2({super.key, required super.child, required this.helper});

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    if (oldWidget is! LenraOauth2) return true;
    return oldWidget.helper != helper;
  }

  static LenraOauth2? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LenraOauth2>();
  }

  static LenraOauth2 of(BuildContext context) {
    final LenraOauth2? result = maybeOf(context);
    assert(result != null, 'No LenraApp found in context');
    return result!;
  }
}
