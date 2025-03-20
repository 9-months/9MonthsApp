import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:_9months/services/auth_service.dart';
import 'package:_9months/models/user_model.dart' as user;
import 'package:_9months/config/config.dart';

// Create mocks using Mockito
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}
class MockHttpClient extends Mock implements http.Client {}

// TestAuthService subclass to inject mocks
class TestAuthService extends AuthService {
  final GoogleSignIn googleSignInInstance;
  final http.Client httpClient;

  TestAuthService({required this.googleSignInInstance, required this.httpClient});

  @override
  Future<user.User> googleSignIn({Map<String, dynamic>? extraData}) async {
    try {
      // Use injected GoogleSignIn instance instead of the default one.
      final GoogleSignInAccount? googleUser = await googleSignInInstance.signIn();
      if (googleUser == null) throw Exception('Google sign in cancelled');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception('Failed to get ID Token');

      // Prepare payload with idToken and any extra registration data.
      final Map<String, dynamic> payload = {'idToken': idToken};
      if (extraData != null) {
        payload.addAll(extraData);
      }

      // Use the injected HTTP client for making API calls.
      final response = await httpClient.post(
        Uri.parse('${Config.apiBaseUrl}/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return user.User.fromJson(data['user']);
      } else {
        throw Exception('Google sign in failed');
      }
    } catch (e) {
      throw Exception('Google sign in failed: ${e.toString()}');
    }
  }
}

void main() {
  group('AuthService Google SignIn Tests', () {
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuth;
    late MockHttpClient mockHttpClient;
    late TestAuthService authService;

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuth = MockGoogleSignInAuthentication();
      mockHttpClient = MockHttpClient();

      authService = TestAuthService(
        googleSignInInstance: mockGoogleSignIn,
        httpClient: mockHttpClient,
      );
    });

    test('Successful Google SignIn without extra data', () async {
      // Arrange: Simulate successful Google sign in flow.
      when(mockGoogleSignIn.signIn())
          .thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication)
          .thenAnswer((_) async => mockGoogleSignInAuth);
      when(mockGoogleSignInAuth.idToken).thenReturn('dummy_id_token');

      // Arrange: Simulate a successful HTTP response.
      final userJson = {'id': '123', 'email': 'test@example.com'};
      final responseBody = json.encode({'user': userJson});
      when(mockHttpClient.post(
        any(),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await authService.googleSignIn();

      // Assert: Validate that the returned user data is correct.
      expect(result, isNotNull);
      expect(result.uid, equals('123'));
      expect(result.email, equals('test@example.com'));
    });

    test('Google SignIn fails if sign in is cancelled', () async {
      // Arrange: Simulate user cancellation of Google sign in.
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () async => await authService.googleSignIn(),
        throwsA(predicate((e) =>
            e.toString().contains('Google sign in cancelled'))),
      );
    });
  });
}