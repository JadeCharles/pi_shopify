import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

class MultipassToken {
  /// Creates a Multipass token from a given [secret] and [data]. The resulting token ca n be used to create the Multipass redirect url
  static String createMutlipassToken({required String multipassSecret, required Map<String, dynamic> customerJson}) {
    final customerJsonText = jsonEncode(customerJson);

    // Convert secret to bytes so it's easier to work with
    final Uint8List secretBytes = Uint8List.fromList(utf8.encode(multipassSecret));
    // Hash the secret bytes ("secret bytes" is a funny phrase)
    final Uint8List hashedSecretBytes = Uint8List.fromList(sha256.convert(secretBytes).bytes);

    // Split the secret bytes into two parts (encryption key and HMAC key)
    final Uint8List encryptionKey = hashedSecretBytes.sublist(0, 16);
    final Uint8List signatureKey = hashedSecretBytes.sublist(16);

    final Key key = Key(encryptionKey);

    // Create the initialization vector with random bytes
    final IV iv = IV.fromSecureRandom(16);

    final AES aesCypher = AES(key, mode: AESMode.cbc);
    final Encrypter encrypter = Encrypter(aesCypher);

    // Encrypt the customer text data
    final Encrypted cypherText = encrypter.encrypt(customerJsonText, iv: iv);
    final Uint8List encryptedBytes = Uint8List.fromList(cypherText.bytes);

    final Uint8List cipher = Uint8List.fromList(iv.bytes + encryptedBytes);
    final Uint8List signedBytes = sign(cipher, signatureKey: signatureKey);

    // Combine the cipher and the signature, then base64 encode the result...
    // Replace the requisite characters to make it url-friendly... And there you have it.
    return base64.encode(cipher + signedBytes).replaceAll("+", "-").replaceAll("/", "_");
  }

  /// Signs the encrypted data with the signatureKey
  static Uint8List sign(Uint8List data, {required Uint8List signatureKey}) {
    var hmacSha256 = Hmac(sha256, signatureKey); // HMAC-SHA256
    final digest = hmacSha256.convert(data);
    return Uint8List.fromList(digest.bytes);
  }

  /// Format the Multipass token into a redirect url
  static String createRedirectUrl({required String token, required String shopDomain, String? returnToPath}) {
    final returnPath = returnToPath != null ? "?return_to=${returnToPath.replaceAll("?", "%3F")}" : "";

    return "https://$shopDomain.myshopify.com/account/login/multipass/$token$returnPath";
  }
}
