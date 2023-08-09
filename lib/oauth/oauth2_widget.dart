import 'package:flutter/material.dart';
import 'package:lenra/lenra.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:provider/provider.dart';

/// A widget that handles the Lenra OAuth2 authentication flow.
class LenraOauth2Widget extends StatelessWidget {
  final Widget? child;

  /// Creates a new instance of [LenraOauth2Widget].
  const LenraOauth2Widget({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LenraOauth2Client oauth2 = LenraOauth2Client();

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
