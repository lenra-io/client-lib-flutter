import 'package:flutter/material.dart';
import 'package:lenra_client/widgets.dart';

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
      home: LenraApplication(
          clientId: 'XXX-XXX-XXX',
          child: const MyHomePage(title: 'Flutter Demo Home Page'),
          loginWidgetBuilder: (BuildContext context, VoidCallback login) =>
              Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: login,
                    child: const Text("Login"),
                  ),
                ),
              )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return LenraView(
      route: "/counter/me",
      builder: (
        BuildContext context,
        Map<String, dynamic> json,
        ListenerCaller callListener,
      ) =>
          Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
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
          onPressed: () {
            setState(() {
              _loading = true;
            });
            callListener(json["onIncrement"] as Map<String, dynamic>
                  ..["event"] = {"value": "custom value"})
                .then((_) {
              setState(() {
                _loading = false;
              });
            });
          },
          tooltip: 'Increment',
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
      loader: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
