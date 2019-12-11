import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:serial_number/serial_number.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _serial = "";
  var _passwd = "";
  var _perc = 0.0;
  var _barColor = Colors.blue;
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    generatePassword(sn) {
      setState(() {
        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyyMMddkkmm').format(now);
        var input = "$sn$formattedDate";
        _passwd = md5.convert(utf8.encode(input)).toString();
        _passwd =
            _passwd.substring(_passwd.length - 6, _passwd.length).toUpperCase();

        _perc = 1 - now.second / 60;
        if (_perc < 0.1)
          _barColor = Colors.red;
        else
          _barColor = Colors.blue;
      });
    }

    // SerialNumber.serialNumber.then(
    //   (sn) {
    //     _serial = sn;
    //     generatePassword(sn);
    //   },
    // );

    new SerialStorage().readSerial().then(
      (sn) {
        _serial = sn;
        generatePassword(sn);
      },
    );

    new Timer(new Duration(milliseconds: 100), () {
      generatePassword(_serial);
    });

    void _showDeviceNumber() {
      _obscureText = !_obscureText;
    }

    var materialApp = new MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Password Generator'),
          backgroundColor: Colors.blueGrey[900],
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('images/chiave.png'),
                backgroundColor: Colors.white12,
              ),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: new LinearPercentIndicator(
                  lineHeight: 20.0,
                  percent: _perc,
                  progressColor: _barColor,
                ),
              ),
              Text(
                '$_passwd',
                style: TextStyle(
                  fontSize: 60,
                  fontFamily: 'IBMPlexMono',
                  color: Colors.white,
                ),
              ),
              Visibility(
                visible: !_obscureText,
                child: Text(
                  '$_serial',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.lightBlue.shade900,
        floatingActionButton: new FloatingActionButton(
          onPressed: _showDeviceNumber,
          tooltip: 'Increment',
          child: new Icon(Icons.announcement),
        ),
      ),
    );

    return materialApp;
  }
}


class SerialStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;

    return File('$path/serial.txt');
  }

  Future<String> readSerial() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      String newSerial = generaNumeroSerie();
      writeSerial(newSerial);
      return newSerial;
    }
  }

  Future<File> writeSerial(String serial) async {
    final file = await _localFile;
    return file.writeAsString('$serial');
  }

  String generaNumeroSerie() {
    String caratteri = "01234567890ABCDEFGHILJKMNOPRSTVWXYZ";
    String sn = "";
    for(int i = 0; i < 10; i++){
      var idx =  Random().nextInt(caratteri.length);
      sn += caratteri.substring(idx, idx+1);
    }
    return sn;
  }
}

