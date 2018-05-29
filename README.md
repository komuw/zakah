## Zakah          

[![CircleCI](https://circleci.com/gh/komuw/zakah.svg?style=svg)](https://circleci.com/gh/komuw/zakah)

Zakah is a client library for safaricom's Mpesa API.           
It's name is derived from Kenyan hip hop artiste, Zakah.                        
It allows you to integrate with [safaricom mpesa API.](https://developer.safaricom.co.ke/)       

It's currently work in progress, API will remain unstable for sometime.


> M-Pesa (M for mobile, pesa is Swahili for money) is a mobile phone-based money transfer, financing and microfinancing service, launched in 2007 by Safaricom, the largest mobile network operator in Kenya. It has since expanded to Afghanistan, South Africa, India, Romania and Albania. M-Pesa allows users to deposit, withdraw, transfer money and pay for goods and services easily with a mobile device. - https://en.wikipedia.org/wiki/M-Pesa



## Installation
add the following to your `pubspec.yaml` file;
```shell
dependencies:
  zakah: <1.0.0
```
then run;
```shell
pub get
```             
or with flutter;
```shell
flutter packages get
```
now, in your Dart code, you can use:
```shell
import 'package:zakah/zakah.dart';
```

this lib is also available at [Pub package repository](https://pub.dartlang.org/packages/zakah)    

## Usage

```dart
import 'dart:async';
import 'package:zakah/zakah.dart' as zakah;

Future<void> main() async {
  var m =
      new zakah.Mpesa('KNJH6N40cjL8saPjDmJxvcx1AyVywVzw', 'SQhQ4EeOXMTe96D5');
  Map b2cResult = await await m.b2c(
      "apitest390",
      "SecurityCredential",
      zakah.CommandID["BusinessPayment"],
      300,
      "601390",
      "254708374149",
      "some remaks",
      Uri.parse("https://www.google.com"),
      Uri.parse("https://www.google.com"),
      occasion: "some occasion");

  print("final b2cResult::");
  print(b2cResult);
}
```


## Features
- todo

## Development setup
- fork this repo.
- you need to have dart version2 installed.
- open an issue on this repo. In your issue, outline what it is you want to add and why.              
- make the changes you want on your fork.
- your changes should have backward compatibility in mind unless it is impossible to do so.
- add tests
- format your code using [dartfmt](https://github.com/dart-lang/dart_style):                      
```shell
dartfmt --overwrite --profile --follow-links .
```
- run tests and make sure everything is passing:
```shell
pub run test .
```
- open a pull request on this repo.               
NB: I make no commitment of accepting your pull requests.                
