import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:oauth2_client/oauth2_response.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// A class that represents a Lenra OAuth2 client.
class LenraOauth2Helper extends OAuth2Helper {
  String baseUri;

  /// Creates the helper usable to refresh the OAuth2 token.
  LenraOauth2Helper({
    required this.baseUri,
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

  @override
  Future<OAuth2Response> disconnect({httpClient}) async {
    var response = super.disconnect(httpClient: httpClient);
    await _oauthDisconnect();
    return await response;
  }

  Future<void> _oauthDisconnect() async {
    String urlStr = '$baseUri/oauth2/sessions/logout';
    if (await canLaunchUrlString(urlStr)) {
      await launchUrlString(urlStr);
    } else {
      throw "Could not launch $urlStr";
    }
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

@deprecated
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

class LenraOauth2Controller extends ChangeNotifier {
  final LenraOauth2Helper helper;
  LoginStatus _status = LoginStatus.loggedOut;
  AccessTokenResponse? _token;
  Object? _error;
  _LoginAction _action = _LoginAction.none;

  LenraOauth2Controller(this.helper);

  LoginStatus get status => _status;
  AccessTokenResponse? get token => _token;
  Object? get error => _error;

  Future<void> checkAuthentication() async {
    if (_action != _LoginAction.none) {
      throw StateError("There is already a login or logout action in progress");
    }

    _action = _LoginAction.checkAuthentication;
    _status = LoginStatus.pending;
    _token = null;
    _error = null;
    notifyListeners();

    try {
      if (await helper.isAuthenticated()) {
        _token = await helper.getTokenFromStorage();
        _status = LoginStatus.loggedIn;
      } else {
        _status = LoginStatus.loggedOut;
      }
      _action = _LoginAction.none;
      notifyListeners();
    } catch (e) {
      _error = e;
      _status = LoginStatus.error;
      _action = _LoginAction.none;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login() async {
    if (_action != _LoginAction.none) {
      throw StateError("There is already a login or logout action in progress");
    }

    _action = _LoginAction.login;
    _status = LoginStatus.pending;
    _token = null;
    _error = null;
    notifyListeners();

    try {
      _token = await helper.getToken();
      // TODO: Manage if the token is null ?
      _status = LoginStatus.loggedIn;
      _action = _LoginAction.none;
      notifyListeners();
    } catch (e) {
      _error = e;
      _status = LoginStatus.error;
      _action = _LoginAction.none;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    if (_action != _LoginAction.none) {
      throw StateError("There is already a login or logout action in progress");
    }

    _action = _LoginAction.logout;
    _status = LoginStatus.pending;
    _token = null;
    _error = null;
    notifyListeners();

    try {
      await helper.disconnect();
      _status = LoginStatus.loggedOut;
      _action = _LoginAction.none;
      notifyListeners();
    } catch (e) {
      _error = e;
      _status = LoginStatus.error;
      _action = _LoginAction.none;
      notifyListeners();
      rethrow;
    }
  }
}

enum LoginStatus {
  loggedOut,
  pending,
  loggedIn,
  error,
}

enum _LoginAction {
  checkAuthentication,
  login,
  logout,
  none,
}
