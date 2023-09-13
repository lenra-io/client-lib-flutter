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

<h3 align="center">Lenra's Flutter client lib</h3>

  <p align="center">
    Let you create your Flutter application with Lenra backend.
    <br />
    <br />
    <a href="https://github.com/lenra-io/client-lib-flutter/issues">Report Bug</a>
    ·
    <a href="https://github.com/lenra-io/client-lib-flutter/issues">Request Feature</a>
  </p>
</div>




<!-- GETTING STARTED -->

## Prerequisites

Add the dependency to your project:

```console
flutter pub add lenra_client
```

You might need some other prerequisites since this lib is still in using [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage).
Look at this lib documentation to see what you need.

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage

Add a `LenraApplication` to your app:

```dart
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
        appName: 'Example Client',
        // set your own client id for production
        clientId: 'XXX-XXX-XXX',
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}
```

This while automatically start the authentication flow.

You can then add `LenraView` instances to your widget tree to link the widget to a Lenra view and use it data:

```dart
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

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
          onPressed: () => callListener(json["onIncrement"]),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
      loader: const CircularProgressIndicator(),
    );
  }
}
```

For the web target, you also have to add the following JavaScript to a redirect file (default to `redirect.html`) to handle OAuth2 redirection (see the [example](./example/web/redirect.html)):

```javascript
window.onload = function() {
  window.opener.postMessage(window.location.href, `${window.location.protocol}//${window.location.host}`);
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

Project Link: [https://github.com/lenra-io/client-lib-flutter](https://github.com/lenra-io/client-lib-flutter)

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/lenra-io/client-lib-flutter.svg?style=for-the-badge
[contributors-url]: https://github.com/lenra-io/client-lib-flutter/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/lenra-io/client-lib-flutter.svg?style=for-the-badge
[forks-url]: https://github.com/lenra-io/client-lib-flutter/network/members
[stars-shield]: https://img.shields.io/github/stars/lenra-io/client-lib-flutter.svg?style=for-the-badge
[stars-url]: https://github.com/lenra-io/client-lib-flutter/stargazers
[issues-shield]: https://img.shields.io/github/issues/lenra-io/client-lib-flutter.svg?style=for-the-badge
[issues-url]: https://github.com/lenra-io/client-lib-flutter/issues
[license-shield]: https://img.shields.io/github/license/lenra-io/client-lib-flutter.svg?style=for-the-badge
[license-url]: https://github.com/lenra-io/client-lib-flutter/blob/master/LICENSE
