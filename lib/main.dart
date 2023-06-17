import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  final TextEditingController realController = TextEditingController();
  final TextEditingController dolarController = TextEditingController();
  final TextEditingController euroController = TextEditingController();

  late double dolar;
  late double euro;

  void realChanged(String text) {
    if (text.isEmpty) {
      dolarController.text = "";
      euroController.text = "";
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void dolarChanged(String text) {
    if (text.isEmpty) {
      realController.text = "";
      euroController.text = "";
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    if (text.isEmpty) {
      realController.text = "";
      dolarController.text = "";
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  setDolar(double dolar) {
    setState(() {
      widget.dolar = dolar;
    });

    widget.realController.text =
        (dolar * double.parse(widget.realController.text)).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        brightness: Brightness.dark,
        fontFamily: 'Georgia',
      ),
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.amber,
          centerTitle: true,
          title: const Text('\$ Conversor \$'),
        ),
        body: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(
                    child: Text(
                      'Carregando Dados...',
                      style: TextStyle(color: Colors.amber, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                case ConnectionState.active:
                default:
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Erro ao Carregar Dados :(',
                        style: TextStyle(color: Colors.amber, fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else {
                    widget.dolar = snapshot.data!["results"]["currencies"]
                            ["USD"]["buy"] ??
                        0;
                    widget.euro = snapshot.data!["results"]["currencies"]["EUR"]
                            ["buy"] ??
                        0;
                    log(snapshot.data.toString());
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(13.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(Icons.monetization_on,
                                size: 150.0, color: Colors.amber),
                            const SizedBox(height: 20.0),
                            buildTextField('Reais', 'R\$ ',
                                widget.realController, widget.realChanged),
                            const SizedBox(height: 20.0),
                            buildTextField('Dólares', 'US\$ ',
                                widget.dolarController, widget.dolarChanged),
                            const SizedBox(height: 20.0),
                            buildTextField('Euros', '€ ', widget.euroController,
                                widget.euroChanged),
                          ],
                        ),
                      ),
                    );
                  }
              }
            }),
      ),
    );
  }
}

Future<Map> getData() async {
  const request = "https://api.hgbrasil.com/finance?key=d913eb65";

  Uri uri = Uri.parse(request);
  http.Response response = await http.get(uri);
  return convert.json.decode(response.body);
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function? f) {
  return TextField(
    controller: c,
    onChanged: f as void Function(String)?,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.amber),
      border: const OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: const TextStyle(color: Colors.amber),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
  );
}
