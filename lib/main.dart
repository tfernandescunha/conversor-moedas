import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request = 'https://api.hgbrasil.com/finance?format=json&key=f76c43ea';
//my key => f76c43ea

void main() async {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
    ),
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);

  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    if (text == '') {
      this._clearAllFields();
    } else {
      double real = double.parse(text);
      dolarController.text = (real / this.dolar).toStringAsFixed(2);
      euroController.text = (real / this.euro).toStringAsFixed(2);
    }
  }

  void _dolarChanged(String text) {
    if (text == '') {
      this._clearAllFields();
    } else {
      double dolar = double.parse(dolarController.text);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar / this.euro).toStringAsFixed(2);
    }
  }

  void _euroChanged(String text) {
    if (text == '') {
      this._clearAllFields();
    } else {
      double euro = double.parse(euroController.text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / this.dolar).toStringAsFixed(2);
    }
  }

  void _clearAllFields() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor de Moedas \$'),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<Map>(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return TextoInformacao('Carregando os dados...aguarde...');
            default:
              {
                if (snapshot.hasError == true) {
                  return TextoInformacao('Erro ao carregar dados :(');
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        Divider(),
                        buildTextNumberField('Reais', 'R\$', realController, _realChanged),
                        Divider(),
                        buildTextNumberField('Dólares', '\$', dolarController, _dolarChanged),
                        Divider(),
                        buildTextNumberField('Euros', '€', euroController, _euroChanged),
                      ],
                    ),
                  );
                }
              }
          }
        },
        future: getData(),
      ),
    );
  }
}

Widget buildTextNumberField(
    String label, String prefix, TextEditingController textControler, Function changeFunc) {
  return TextField(
    controller: textControler,
    onChanged: changeFunc,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
  );
}

class TextoInformacao extends StatelessWidget {
  final String textInfo = '';

  const TextoInformacao(textInfo);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        textInfo,
        style: TextStyle(
          color: Colors.amber,
          fontSize: 25.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
