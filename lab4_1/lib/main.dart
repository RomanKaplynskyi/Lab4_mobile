import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _light = true;
Future<bool?> _lightF = Future(() => true);
ThemeData _darkTheme = ThemeData(
  accentColor: Colors.red,
  brightness: Brightness.dark,
  primaryColor: Colors.amber,
);

ThemeData _lightTheme = ThemeData(
    accentColor: Colors.pink,
    brightness: Brightness.light,
    primaryColor: Colors.blue);
void main() async {
  runApp(MyApp());
}

Map parseJson(String rawJson) {
  return jsonDecode(rawJson);
}

void onButtonPress(BuildContext context) async {}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SharedPreferencesDemo();
  }
}

class SharedPreferencesDemo extends StatefulWidget {
  SharedPreferencesDemo({Key? key}) : super(key: key);
  @override
  SharedPreferencesDemoState createState() => SharedPreferencesDemoState();
}

bool firstLoad = true;

class SharedPreferencesDemoState extends State<SharedPreferencesDemo> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _json = "";
  _saveTheme() async {
    SharedPreferences pref = await _prefs;
    pref.setBool('theme', _light);
  }

  _getTheme() async {
    _lightF = _prefs.then((SharedPreferences prefs) {
      return prefs.getBool('theme') != null ? prefs.getBool('theme') : true;
    });
    _light = await _lightF as bool;
    print(_light);
  }

  @override
  void initState() {
    super.initState();
    _getTheme();
  }

  @override
  Widget build(BuildContext mainContext) {
    return FutureBuilder<bool?>(
        future: _lightF,
        builder: (BuildContext context, AsyncSnapshot<bool?> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const CircularProgressIndicator();
            default:
              if (firstLoad) {
                _light = snapshot.data as bool;
                firstLoad = false;
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return MaterialApp(
                  title: 'SharedPreferences Demo',
                  home: Scaffold(
                      appBar: AppBar(
                        title: Text("Lab"),
                      ),
                      body: Row(
                        children: <Widget>[
                          Switch(
                              value: _light,
                              onChanged: (state) {
                                setState(() {
                                  _light = state;
                                });
                                _saveTheme();
                              }),
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all<Color>(Colors.blue),
                            ),
                            onPressed: () async {
                              var jsonResp = await http.get(Uri.parse(
                                  'https://jsonplaceholder.typicode.com/albums/1'));
                              var decodedJson = parseJson(jsonResp.body);
                              setState(() {
                                _json = jsonResp.body;
                              });
                            },
                            child: Text('TextButton'),
                          ),
                          Text(_json)
                        ],
                      )),
                  theme: _light ? _lightTheme : _darkTheme,
                );
              }
          }
        });
  }
}
