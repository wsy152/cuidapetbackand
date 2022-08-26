
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:dotenv/dotenv.dart';

class JwtHelper {
  static final String _jwtSecrety = env['JWT_SECRET'] ?? env['jwt_secret_dev']!;

  JwtHelper._();

  static String generateJWT(int userId, int? supplierId) {
    final claimSet = JwtClaim(
        issuer: 'cuidapet',
        subject: userId.toString(),
        expiry: DateTime.now().add(Duration(days: 1)),
        notBefore: DateTime.now(),
        issuedAt: DateTime.now(),
        otherClaims: <String, dynamic>{'supplier': supplierId},
        maxAge: Duration(days: 1));
    return 'Bearer ${issueJwtHS256(claimSet, _jwtSecrety)}';
  }

  static JwtClaim getClaims(String token) {
    return verifyJwtHS256Signature(token, _jwtSecrety);
  }
}
