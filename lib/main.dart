import 'package:flutter/material.dart';
import 'package:pi_shopify/multipass_token.dart';

void main() {
  const String email = "customer@buy-stuff.com";
  const String shopDomain = "my-cool-shop";
  const String multipassSecret = "[ENTER-YOUR-MULTIPASS-SECRET-HERE--TELL-NO-ONE]";

  runApp(const MyApp(
    email: email,
    shopDomain: shopDomain,
    multipassSecret: multipassSecret,
  ));
}

class MyApp extends StatelessWidget {
  final String shopDomain;
  final String multipassSecret;

  final String email;
  final String? firstName;
  final String? lastName;
  final String? identifier;

  const MyApp({
    required this.email,
    required this.shopDomain,
    required this.multipassSecret,
    this.firstName,
    this.lastName,
    this.identifier,
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shopify Multipass Demo",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(
        shopDomain,
        multipassSecret,
        email,
        firstName: firstName,
        lastName: lastName,
        identifier: identifier,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String _shopDomain;
  final String _multipassSecret;

  final String _email;
  final String? firstName;
  final String? lastName;
  final String? identifier;

  const MyHomePage(this._shopDomain, this._multipassSecret, this._email, {this.firstName, this.lastName, this.identifier, super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState(_shopDomain, _multipassSecret, _email, firstName, lastName, identifier);
}

class _MyHomePageState extends State<MyHomePage> {
  String _checkoutUrl = "";
  final String shopDomain;
  final String multipassSecret;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? identifier;

  _MyHomePageState(this.shopDomain, this.multipassSecret, this.email, this.firstName, this.lastName, this.identifier);

  void _incrementCounter() {
    // Minimum required customer data for multipass
    final customerJson = {"email": email, "identifier": identifier, "created_at": DateTime.now().toUtc().toIso8601String()};

    // If there's more customer info, go ahead and add it
    if (firstName != null) customerJson["first_name"] = firstName;
    if (lastName != null) customerJson["last_name"] = lastName;

    final token = MultipassToken.createMutlipassToken(customerJson: customerJson, multipassSecret: multipassSecret);

    setState(() {
      _checkoutUrl = MultipassToken.createRedirectUrl(token: token, shopDomain: shopDomain);
      print(_checkoutUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopify Multipass Demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _checkoutUrl,
                maxLines: 12,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: "Generate Multipass Token Url",
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
