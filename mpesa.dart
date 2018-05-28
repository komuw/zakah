import 'dart:io';
import 'dart:async';
import 'dart:convert';

class Mpesa {
  final String consumerKey;
  final String consumerSecret;
  final String b64keySecret;

  String access_token;
  DateTime access_expires_at;

  Mpesa(this.consumerKey, this.consumerSecret)
      : b64keySecret =
            base64Url.encode((consumerKey + ":" + consumerSecret).codeUnits);

  // todo: change this url depending on env, test/live
  static const String baseSafaricomUrl = "sandbox.safaricom.co.ke";

  static Uri getAuthUrl() {
    Uri uri = new Uri(
        scheme: 'https',
        host: baseSafaricomUrl,
        path: '/oauth/v1/generate',
        queryParameters: {'grant_type': 'client_credentials'});
    return uri;
  }

  Future<void> setAccessToken() async {
    // if access token hasn't expired, dont make http call
    DateTime now = new DateTime.now();
    if (access_expires_at != null) {
      if (now.isBefore(access_expires_at)) {
        return;
      }
    }

    // todo: handle exceptions
    HttpClient client = new HttpClient();
    HttpClientRequest f = await client.getUrl(getAuthUrl());
    f.headers.add("Accept", "application/json");
    f.headers.add("Authorization", "Basic " + b64keySecret);
    HttpClientResponse res = await f.close();

    // u should use `await res.drain()` if u aren't reading the body
    await res.transform(utf8.decoder).forEach((bodyString) {
      var jsondecodeBody = jsonDecode(bodyString);
      access_token = jsondecodeBody["access_token"];
      access_expires_at = now
          .add(new Duration(seconds: int.parse(jsondecodeBody["expires_in"])));
    });
  }
}

Future<void> main() async {
  Mpesa m = new Mpesa('consumerKey', 'consumerSecret');
  print("\n acceess before::");
  print(m.access_token);
  print(m.access_expires_at);

  await m.setAccessToken();

  print("\n acceess after::");
  print(m.access_token);
  print(m.access_expires_at);
}
