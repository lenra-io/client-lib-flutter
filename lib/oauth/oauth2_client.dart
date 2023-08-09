import 'dart:developer';

import 'package:lenra/model/token_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:provider/provider.dart';

/// A class that represents a Lenra OAuth2 client.
class LenraOauth2Client {
  late OAuth2Helper helper;

  /// Creates the helper usable to refresh the OAuth2 token.
  LenraOauth2Client() {
    helper = OAuth2Helper(
      OAuth2Client(
          authorizeUrl: 'http://localhost:4444/oauth2/auth',
          tokenUrl: 'http://localhost:4444/oauth2/token',
          revokeUrl: 'http://localhost:4444/oauth2/revoke',
          redirectUri: redirectUrl,
          customUriScheme: 'com.example.client'),
      grantType: OAuth2Helper.authorizationCode,
      clientId: 'XXX-XXX-XXX',
      clientSecret: 'XXX-XXX-XXX',
      scopes: ["app:websocket"],
    );
  }

  /// Returns the redirect URL based on the platform.
  get redirectUrl => kIsWeb
      ? 'http://localhost:${Uri.base.port}/redirect.html'
      : 'com.example.client://';

  /// Refreshes the OAuth2 token.
  Future<AccessTokenResponse?> refreshToken() async {
    var resp = await helper.getToken();

    // print(resp.body); but with logging driver
    log(resp!.accessToken!, name: 'lenra_oauth2_client');
    return resp;
  }
}

/// A widget that handles the Lenra OAuth2 authentication flow.
class LenraOauth2Widget extends StatelessWidget {
  final Widget? child;

  /// Creates a new instance of [LenraOauth2Widget].
  const LenraOauth2Widget({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LenraOauth2Client oauth2 = LenraOauth2Client();

    return FutureBuilder(
      future: oauth2.refreshToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error ${snapshot.error}');
          }
          context.read<TokenProvider>().token =
              snapshot.data as AccessTokenResponse;
          return child!;
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
