<div id="top"></div>
<!--
*** This README was created with https://github.com/othneildrew/Best-README-Template
-->



<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">

<h3 align="center">Lib flutter client</h3>

  <p align="center">
    This lib provides just enough to get started creating your application with lenra backend.
    <br />
    <br />
    <a href="https://github.com/lenra-io/template-javascript/issues">Report Bug</a>
    ·
    <a href="https://github.com/lenra-io/template-javascript/issues">Request Feature</a>
  </p>
</div>




<!-- GETTING STARTED -->

## Prerequisites

Add the dependency to your project:

```console
flutter pub add lenra_client_lib
```

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage

Add a `LenraApplicationWidget` to your app:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lenra_client/lenra_client.dart';

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
        appName: 'Example Client',
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
```

This while automatically start the authentication flow.

You can then add `LenraWidget` instances to your widget tree to link the widget to a Lenra view and use it data:

```dart
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
```

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please open an issue with the tag "enhancement".
Don't forget to give the project a star if you liked it! Thanks again!

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the **MIT** License. See [LICENSE](./LICENSE) for more information.

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Lenra - [@lenra_dev](https://twitter.com/lenra_dev) - contact@lenra.io

Project Link: [https://github.com/lenra-io/template-javascript](https://github.com/lenra-io/template-javascript)

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/lenra-io/template-javascript.svg?style=for-the-badge
[contributors-url]: https://github.com/lenra-io/template-javascript/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/lenra-io/template-javascript.svg?style=for-the-badge
[forks-url]: https://github.com/lenra-io/template-javascript/network/members
[stars-shield]: https://img.shields.io/github/stars/lenra-io/template-javascript.svg?style=for-the-badge
[stars-url]: https://github.com/lenra-io/template-javascript/stargazers
[issues-shield]: https://img.shields.io/github/issues/lenra-io/template-javascript.svg?style=for-the-badge
[issues-url]: https://github.com/lenra-io/template-javascript/issues
[license-shield]: https://img.shields.io/github/license/lenra-io/template-javascript.svg?style=for-the-badge
[license-url]: https://github.com/lenra-io/template-javascript/blob/master/LICENSE
