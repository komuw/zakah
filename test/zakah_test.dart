import "package:test/test.dart";
import 'package:zakah/zakah.dart' as zakah;

void main() {
  test("Mpesa.consumerKey returns right key", () {
    var m = zakah.Mpesa('MyconsumerKey', 'MyconsumerSecret');
    expect(m.consumerKey, equals("MyconsumerKey"));
  });

  test("Mpesa.MyconsumerSecret returns right secret", () {
    var m = zakah.Mpesa('MyconsumerKey', 'MyconsumerSecret');
    expect(m.consumerSecret, equals("MyconsumerSecret"));
  });
}
