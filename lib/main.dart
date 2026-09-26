import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/session_app.dart';
import 'firebase_options.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/locale_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/web/public_web_landing.dart';
import 'screens/web/web_auth_wrapper.dart';
import 'services/auth_service.dart';
import 'utils/app_palette.dart';

/// Адрес эмуляторов Firebase для локальной отладки (только в debug-сборке):
/// `flutter run --dart-define=FIREBASE_EMULATOR=localhost` (Android-эмулятор: 10.0.2.2).
/// Эмуляторы запускаются с `--project nectar-41848` (локально, в боевую базу не ходят).
/// Пусто — боевой проект.
const String _emulatorHost = String.fromEnvironment('FIREBASE_EMULATOR');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final useEmulator = kDebugMode && _emulatorHost.isNotEmpty;
  if (useEmulator) {
    await FirebaseAuth.instance.useAuthEmulator(_emulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(_emulatorHost, 8080);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..load()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  late final Stream<User?> _authStream = _authService.authStateChanges;
  StreamSubscription<User?>? _sessionSubscription;
  String? _sessionUserId;

  bool _splashFinished = kIsWeb;
  bool _onboardingFinished = false;

  @override
  void initState() {
    super.initState();
    _sessionUserId = _authService.currentUser?.uid;
    context.read<FavoriteProvider>().bindUser(_sessionUserId);
    _sessionSubscription = _authService.authStateChanges.listen(_onAuthChanged);
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    super.dispose();
  }

  void _onAuthChanged(User? user) {
    if (!mounted || user?.uid == _sessionUserId) return;

    _sessionUserId = user?.uid;
    context.read<CartProvider>().clear();
    context.read<FavoriteProvider>().bindUser(_sessionUserId);
  }

  Widget _homeFor(User? user, {required bool authResolved}) {
    if (!authResolved) {
      return const _LoadingScreen();
    }

    if (!_splashFinished) {
      return SplashScreen(onFinished: () => setState(() => _splashFinished = true));
    }

    if (kIsWeb) {
      return user == null ? const PublicWebLandingScreen() : WebRoleGate(user: user);
    }

    if (user != null) {
      return AuthenticatedShell(user: user);
    }

    if (!_onboardingFinished) {
      return OnboardingScreen(onFinished: () => setState(() => _onboardingFinished = true));
    }

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AuthService.gateHold,
      builder: (context, isGateHeld, _) {
        return StreamBuilder<User?>(
          stream: _authStream,
          initialData: _authService.currentUser,
          builder: (context, snapshot) {
            // On the web the persisted session is restored asynchronously, so
            // the first frame must wait for the first auth event.
            final authResolved = !kIsWeb ||
                snapshot.connectionState != ConnectionState.waiting ||
                snapshot.data != null;
            final user = isGateHeld ? null : snapshot.data;

            return SessionApp(
              locale: context.watch<LocaleProvider>().locale,
              sessionId: authResolved ? user?.uid : null,
              home: _homeFor(user, authResolved: authResolved),
            );
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: AppPalette.primary)),
    );
  }
}
