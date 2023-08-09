import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';

class TokenProvider extends ChangeNotifier {
  AccessTokenResponse? token;
}
