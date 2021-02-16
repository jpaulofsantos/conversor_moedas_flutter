import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const requestAPI = "https://api.hgbrasil.com/finance?key=0fcd9ab3";

void main() async {
  //print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.white70,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          hintStyle: TextStyle(color: Colors.white70),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearFields() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearFields();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white38,
      appBar: AppBar(
        title: Text("Conversor de Moedas"),
        backgroundColor: Colors.white70,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        // ignore: missing_return
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Erro ao carregar dados...",
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Icon(Icons.monetization_on_outlined,
                          size: 120.0, color: Colors.white),
                      Divider(),
                      buildTextField(
                          "Reais", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "Dólares", "US\$ ", dolarController, _dolarChanged),
                      Divider(),
                      buildTextField(
                          "Euros", "€ ", euroController, _euroChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function functionChanged) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(fontSize: 20.0, color: Colors.white),
    onChanged: functionChanged,
    keyboardType: TextInputType.numberWithOptions(decimal: true),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(requestAPI);
  return json.decode(response.body);
}
