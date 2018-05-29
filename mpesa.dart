import 'dart:io';
import 'dart:async';
import 'dart:convert';

const Map<String, String> CommandID = const {
  "TransactionReversal":
      "TransactionReversal", //Reversal for an erroneous C2B transaction.
  "SalaryPayment":
      "SalaryPayment", //	Used to send money from an employer to employees e.g. salaries
  "BusinessPayment":
      "BusinessPayment", //	Used to send money from business to customer e.g. refunds
  "PromotionPayment":
      "PromotionPayment", //	Used to send money when promotions take place e.g. raffle winners
  "AccountBalance":
      "AccountBalance", //	Used to check the balance in a paybill/buy goods account (includes utility, MMF, Merchant, Charges paid account).
  "CustomerPayBillOnline":
      "CustomerPayBillOnline", //	Used to simulate a transaction taking place in the case of C2B Simulate Transaction or to initiate a transaction on behalf of the customer (STK Push).
  "TransactionStatusQuery":
      "TransactionStatusQuery", //	Used to query the details of a transaction.
  "CheckIdentity":
      "CheckIdentity", //	Similar to STK push, uses M-Pesa PIN as a service.
  "BusinessPayBill":
      "BusinessPayBill", //	Sending funds from one paybill to another paybill
  "BusinessBuyGoods":
      "BusinessBuyGoods", //	sending funds from buy goods to another buy goods.
  "DisburseFundsToBusiness":
      "DisburseFundsToBusiness", //	Transfer of funds from utility to MMF account.
  "BusinessToBusinessTransfer":
      "BusinessToBusinessTransfer", //	Transferring funds from one paybills MMF to another paybills MMF account.
  "BusinessTransferFromMMFToUtility":
      "BusinessTransferFromMMFToUtility", //	Transferring funds from paybills MMF to another paybills utility account.
};

const Map<String, int> IdentifierType = const {
  "MSISDN": 1,
  "TillNumber": 2,
  "Shortcode": 4
};

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
    HttpClientRequest req = await client.getUrl(getAuthUrl());
    req.headers.add("Accept", "application/json");
    req.headers.add("Authorization", "Basic " + b64keySecret);
    HttpClientResponse res = await req.close();

    // u should use `await res.drain()` if u aren't reading the body
    await res.transform(utf8.decoder).forEach((bodyString) {
      var jsondecodeBody = jsonDecode(bodyString);
      access_token = jsondecodeBody["access_token"];
      access_expires_at = now
          .add(new Duration(seconds: int.parse(jsondecodeBody["expires_in"])));
    });
  }

  static Uri getB2cUrl() {
    Uri uri = new Uri(
        scheme: 'https',
        host: baseSafaricomUrl,
        path: '/mpesa/b2c/v1/paymentrequest');
    return uri;
  }

  Future<Map<String, String>> b2c(
      String initiatorName,
      String securityCredential,
      String commandid,
      int amount,
      String partyA,
      String partyB,
      String remarks,
      Uri queueTimeOutURL,
      Uri resultURL,
      {String occasion}) async {
    await setAccessToken();

    // this values can be got from; https://developer.safaricom.co.ke/test_credentials
    final b2cPayload = {
      "InitiatorName": initiatorName,
      "SecurityCredential": securityCredential,
      "CommandID": commandid,
      "Amount": amount,
      "PartyA": partyA,
      "PartyB": partyB,
      "Remarks": remarks,
      "QueueTimeOutURL": queueTimeOutURL.toString(),
      "ResultURL": resultURL.toString(),
      "Occasion": occasion
    };
    final Map<String, String> result = new Map<String, String>();

    // todo: handle exceptions
    HttpClient client = new HttpClient();
    HttpClientRequest req = await client.postUrl(getB2cUrl());
    req.headers.add("Content-Type", "application/json");
    req.headers.add("Authorization", "Bearer " + access_token);
    req.write(jsonEncode(b2cPayload)); // write is non-blocking
    HttpClientResponse res = await req.close();

    await res.transform(utf8.decoder).forEach((bodyString) {
      var jsondecodeBody = jsonDecode(bodyString);

      if (res.statusCode == 200) {
        result["ConversationID"] = jsondecodeBody["ConversationID"];
        result["OriginatorConversationID"] =
            jsondecodeBody["OriginatorConversationID"];
        result["ResponseCode"] = jsondecodeBody["ResponseCode"];
        result["ResponseDescription"] = jsondecodeBody["ResponseDescription"];
      } else {
        result["requestId"] = jsondecodeBody["requestId"];
        result["errorCode"] = jsondecodeBody["errorCode"];
        result["errorMessage"] = jsondecodeBody["errorMessage"];
      }
    });
    return result;
  }
}

Future<void> main() async {
  Mpesa m = new Mpesa('KNJH6N40cjL8saPjDmJxvcx1AyVywVzw', 'SQhQ4EeOXMTe96D5');

  // this values can be got from; https://developer.safaricom.co.ke/test_credentials
  Map b2cResult = await m.b2c(
      "apitest390",
      "c6x4tK+uZzTyRtn7vFG//ctViOSfiYCCYGQ4j+xvQfeOC/zbv9Iszr/c6niGtqHRyuLAgGKV0G6zzQtc0QcEIzH9c6fOG/JA03OS5RRFccHI3sCQ0ucVGuYD4FbxM1EMAMgj09C21WGouXiFPenF0wwxFPZLRs9JBFOXfLNPbaA8+03TrYnID1mFR+nDfDT5xOvuk1JWnkmTk9NJDOtT+Fn2dP1DBrMbIW0tmROkMsKm3zCV4QJmKbnr/Ds+/HyXyGmr3UOUU3t9jq973uJ/y6/8TukQmA4dkjXGy7agzAO4pPIYWScpiom3K/JY//Z5EdSUn1f4SYrwHiH8cTmjCw==",
      CommandID["BusinessPayment"],
      300,
      "601390",
      "254708374149",
      "some remaks",
      Uri.parse("https://www.google.com"),
      Uri.parse("https://www.google.com"),
      occasion: "some occasion");

  print("\n \n final b2cResult::");
  print(b2cResult);
}
