import 'package:flutter/material.dart';
import 'package:lenra/lenra.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:provider/provider.dart';

/// A widget that handles the Lenra OAuth2 authentication flow.
class LenraApplicationWidget extends StatelessWidget {
  /// The UI to show after the authentication flow.
  final Widget? child;

  /// The lenra instance's hostname and port.
  final String host;

  /// The OAuth2 redirect URL.
  final String oauthRedirectUrl;

  /// The OAuth2 client ID.
  final String clientId;

  /// The OAuth2 client secret.
  /// This is not secret in the context of a mobile app.
  /// It is only used to identify the app.
  final String? clientSecret;

  /// The OAuth2 scopes.
  /// Defaults to `["app:websocket"]`
  final List<String> scopes;

  /// Creates a new instance of [LenraOauth2Widget].
  const LenraApplicationWidget(
      {Key? key,
      required this.child,
      required this.host,
      required this.oauthRedirectUrl,
      required this.clientId,
      this.clientSecret,
      this.scopes = const ["app:websocket"],
      String? customUriScheme})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    LenraOauth2Client oauth2 = LenraOauth2Client(
      host: host,
      redirectUrl: oauthRedirectUrl,
      clientId: clientId,
      clientSecret: clientSecret,
      customUriScheme: 'com.example.client',
      scopes: scopes,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TokenProvider()),
      ],
      child: FutureBuilder(
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
      ),
    );
  }
}
