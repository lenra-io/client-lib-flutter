import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lenra_client/application.dart';

void main() {
  testWidgets('Basic SimplePage', (WidgetTester tester) async {
    await tester.pumpWidget(LenraApplication(
        child: Text("Hello world"),
        host: "http://localhost:4001",
        oauthRedirectUrl: "com.example.client://",
        appName: "Test",
        clientId: "XXX-XXX-XXX"));

    final widgetFinder = find.byType(LenraApplication);
    final textFinder = find.byType(Text);

    expect(widgetFinder, findsOneWidget);
    expect(textFinder, findsOneWidget);
  });
}
