import 'package:phoenix_wings/phoenix_wings.dart';

PhoenixSocket createPhoenixSocket(
  String endpoint,
  Map<String, String> params,
) =>
    PhoenixSocket(
      endpoint,
      socketOptions: PhoenixSocketOptions(params: params),
    );
