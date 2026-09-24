import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_state.dart';
import 'services/local_store.dart';
import 'screens/setup_page.dart';
import 'screens/home_page.dart';
import 'screens/auth_page.dart';

const teal = Color(0xFF087A6E);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final state = AppState(LocalStore(preferences));
  await state.load();
  runApp(DetectorApp(state: state));
}

class DetectorApp extends StatelessWidget {
  const DetectorApp({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'LossTrack',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: teal),
          scaffoldBackgroundColor: const Color(0xFFF7F9F8),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.black.withAlpha(10)),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            height: 72,
            indicatorColor: teal.withAlpha(28),
            labelTextStyle: WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF0F5F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: teal, width: 1.4),
            ),
          ),
        ),
        home: const SplashPage(),
      ),
    );
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final state = AppScope.of(context);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => !state.store.isLoggedIn
              ? const AuthPage()
              : state.business == null
              ? const SetupPage()
              : const HomePage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: controller,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(
                  'img/logo.jpg',
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                  semanticLabel: 'Logo de LossTrack',
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'LossTrack',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Controla tu negocio, detecta tus pérdidas.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
