import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lenra/lenra.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LenraApplicationWidget(
        clientId: 'XXX-XXX-XXX',
        // If is in debug mode then use the local host else use the remote host
        host: kDebugMode ? 'http://localhost:4444' : 'https://auth.lenra.io',
        oauthRedirectUrl: kIsWeb
            ? '${Uri.base.scheme}://${Uri.base.host}:${Uri.base.port}/redirect.html'
            : 'com.example.client://',
        scopes: const ['app:websocket'],
        customUriScheme: 'com.example.client',
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return LenraWidget(
      route: "/counter/me",
      builder: (ListenerCall listener, Map<String, dynamic> json) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '${json["value"]}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => listener(json["onIncrement"]),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
      loader: const CircularProgressIndicator(),
    );
  }
}
