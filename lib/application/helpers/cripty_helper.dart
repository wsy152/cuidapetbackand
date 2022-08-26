import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart' show sha256;

class CriptyHelper {
  CriptyHelper._();
  static String generateSha256Hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
