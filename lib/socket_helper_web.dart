// ignore: avoid_web_libraries_in_flutter
import 'package:phoenix_wings/html.dart';

PhoenixSocket createPhoenixSocket(
  String endpoint,
  Map<String, String> params,
) =>
    PhoenixSocket(
      endpoint,
      connectionProvider: PhoenixHtmlConnection.provider,
      socketOptions: PhoenixSocketOptions(params: params),
    );
