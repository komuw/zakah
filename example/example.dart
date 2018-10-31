import 'dart:async';
import 'package:zakah/zakah.dart' as zakah;

Future<void> main() async {
  var m = new zakah.Mpesa('KNJH6N40cjL8saPjDmJxvcx1AyVywVzw', 'SQhQ4EeOXMTe96D5');
  Map b2cResult = await m.b2c(
      "apitest390",
      "c6x4tK+uZzTyRtn7vFG//ctViOSfiYCCYGQ4j+xvQfeOC/zbv9Iszr/c6niGtqHRyuLAgGKV0G6zzQtc0QcEIzH9c6fOG/JA03OS5RRFccHI3sCQ0ucVGuYD4FbxM1EMAMgj09C21WGouXiFPenF0wwxFPZLRs9JBFOXfLNPbaA8+03TrYnID1mFR+nDfDT5xOvuk1JWnkmTk9NJDOtT+Fn2dP1DBrMbIW0tmROkMsKm3zCV4QJmKbnr/Ds+/HyXyGmr3UOUU3t9jq973uJ/y6/8TukQmA4dkjXGy7agzAO4pPIYWScpiom3K/JY//Z5EdSUn1f4SYrwHiH8cTmjCw==",
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
