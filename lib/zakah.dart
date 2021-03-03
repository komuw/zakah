import 'dart:io';
import 'dart:async';
import 'dart:convert';

const Map<String, String> CommandID = {
  "TransactionReversal": "TransactionReversal", //Reversal for an erroneous C2B transaction.
  "SalaryPayment":
      "SalaryPayment", //	Used to send money from an employer to employees e.g. salaries
  "BusinessPayment": "BusinessPayment", //	Used to send money from business to customer e.g. refunds
  "PromotionPayment":
      "PromotionPayment", //	Used to send money when promotions take place e.g. raffle winners
  "AccountBalance":
      "AccountBalance", //	Used to check the balance in a paybill/buy goods account (includes utility, MMF, Merchant, Charges paid account).
  "CustomerPayBillOnline":
      "CustomerPayBillOnline", //	Used to simulate a transaction taking place in the case of C2B Simulate Transaction or to initiate a transaction on behalf of the customer (STK Push).
  "TransactionStatusQuery": "TransactionStatusQuery", //	Used to query the details of a transaction.
  "CheckIdentity": "CheckIdentity", //	Similar to STK push, uses M-Pesa PIN as a service.
  "BusinessPayBill": "BusinessPayBill", //	Sending funds from one paybill to another paybill
  "BusinessBuyGoods": "BusinessBuyGoods", //	sending funds from buy goods to another buy goods.
  "DisburseFundsToBusiness":
      "DisburseFundsToBusiness", //	Transfer of funds from utility to MMF account.
  "BusinessToBusinessTransfer":
      "BusinessToBusinessTransfer", //	Transferring funds from one paybills MMF to another paybills MMF account.
  "BusinessTransferFromMMFToUtility":
      "BusinessTransferFromMMFToUtility", //	Transferring funds from paybills MMF to another paybills utility account.
};

const Map<String, int> IdentifierType = {"MSISDN": 1, "TillNumber": 2, "Shortcode": 4};

class Mpesa {
  final String consumerKey;
  final String consumerSecret;
  final String b64keySecret;

  String access_token;
  DateTime access_expires_at;

  Mpesa(this.consumerKey, this.consumerSecret)
      : b64keySecret = base64Url.encode((consumerKey + ":" + consumerSecret).codeUnits);

  // todo: change this url depending on env, test/live
  static const String baseSafaricomUrl = "sandbox.safaricom.co.ke";

  static Uri getAuthUrl() {
    Uri uri = Uri(
        scheme: 'https',
        host: baseSafaricomUrl,
        path: '/oauth/v1/generate',
        queryParameters: <String, String>{'grant_type': 'client_credentials'});
    return uri;
  }

  Future<void> setAccessToken() async {
    // if access token hasn't expired, dont make http call
    DateTime now = DateTime.now();
    if (access_expires_at != null) {
      if (now.isBefore(access_expires_at)) {
        return;
      }
    }

    // todo: handle exceptions
    HttpClient client = HttpClient();
    HttpClientRequest req = await client.getUrl(getAuthUrl());
    req.headers.add("Accept", "application/json");
    req.headers.add("Authorization", "Basic " + b64keySecret);
    HttpClientResponse res = await req.close();

    // u should use `await res.drain()` if u aren't reading the body
    await utf8.decoder.bind(res).forEach((bodyString) {
      dynamic jsondecodeBody = jsonDecode(bodyString);
      access_token = jsondecodeBody["access_token"].toString();
      access_expires_at =
          now.add(Duration(seconds: int.parse(jsondecodeBody["expires_in"].toString())));
    });
  }

  static Uri getB2cUrl() {
    Uri uri = Uri(scheme: 'https', host: baseSafaricomUrl, path: '/mpesa/b2c/v1/paymentrequest');
    return uri;
  }

  Future<Map<String, String>> b2c(String initiatorName, String securityCredential, String commandid,
      int amount, String partyA, String partyB, String remarks, Uri queueTimeOutURL, Uri resultURL,
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
    final Map<String, String> result = Map<String, String>();

    // todo: handle exceptions
    HttpClient client = HttpClient();
    HttpClientRequest req = await client.postUrl(getB2cUrl());
    req.headers.add("Content-Type", "application/json");
    req.headers.add("Authorization", "Bearer " + access_token);
    req.write(jsonEncode(b2cPayload)); // write is non-blocking
    HttpClientResponse res = await req.close();

    await utf8.decoder.bind(res).forEach((bodyString) {
      dynamic jsondecodeBody = jsonDecode(bodyString);

      if (res.statusCode == 200) {
        result["ConversationID"] = jsondecodeBody["ConversationID"].toString();
        result["OriginatorConversationID"] = jsondecodeBody["OriginatorConversationID"].toString();
        result["ResponseCode"] = jsondecodeBody["ResponseCode"].toString();
        result["ResponseDescription"] = jsondecodeBody["ResponseDescription"].toString();
      } else {
        result["requestId"] = jsondecodeBody["requestId"].toString();
        result["errorCode"] = jsondecodeBody["errorCode"].toString();
        result["errorMessage"] = jsondecodeBody["errorMessage"].toString();
      }
    });
    return result;
  }
}
