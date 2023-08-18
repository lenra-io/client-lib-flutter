import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';

/// A class that represents a Lenra OAuth2 client.
class LenraOauth2Client {
  late OAuth2Helper helper;

  /// Creates the helper usable to refresh the OAuth2 token.
  LenraOauth2Client(
      {required String host,
      required String redirectUri,
      required String clientId,
      required String customUriScheme,
      String? clientSecret,
      List<String> scopes = const []}) {
    helper = OAuth2Helper(
      OAuth2Client(
          authorizeUrl: '$host/oauth2/auth',
          tokenUrl: '$host/oauth2/token',
          revokeUrl: '$host/oauth2/revoke',
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
