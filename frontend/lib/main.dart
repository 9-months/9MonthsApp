import 'package:_9months/screens/home/partner_home_page.dart';
import 'package:_9months/screens/journal/diary_screen.dart';
import 'package:_9months/screens/journal/journal_options_screen.dart';
import 'package:_9months/screens/journal/mood_tracking.dart';
import 'package:_9months/screens/news/news_Feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/pregnancy_provider.dart';
import 'screens/auth/login_page.dart';
import 'screens/auth/register_page.dart';
import 'screens/home/home_page.dart';
import 'screens/profile/profile_page.dart';
import 'screens/splash/splash.dart';
import 'screens/onboarding/step_screen.dart';
import 'screens/calendar/calendar_screen.dart'; // Import CalendarScreen
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/profile/profile_form.dart';

// Add this at the top of the file
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PregnancyProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: MaterialApp(
        navigatorKey: navigatorKey, // Add this line
        debugShowCheckedModeBanner: false,
        title: 'Nine Months',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3), // Primary blue color
            primary: const Color(0xFF2196F3),
            secondary: const Color(0xFF03A9F4),
            tertiary: const Color(0xFFE91E63), // Pink for accents
            surface: const Color(0xFFF5F5F5),
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Color(0xFF1F2937)),
            titleTextStyle: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDC2626)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/step': (context) => const StepScreen(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/partner-home': (context) => const PartnerHomePage(),
          '/profile': (context) => const ProfilePage(),
          '/calendar': (context) => CalendarScreen(
                userId:
                    Provider.of<AuthProvider>(context, listen: false).user!.uid,
              ),
          '/journal': (context) => const JournalOptionsScreen(),  
          '/journal/diary': (context) => const DiaryScreen(),     
          '/journal/mood': (context) => const MoodTrackingScreen(),
          '/news': (context) => const NewsFeed(),
          '/profile/form': (context) => ProfileForm(),
        },
      ),
    );
  }
}

// Add this keyboard handler widget
class KeyboardDismisser extends StatelessWidget {
  final Widget child;
  
  const KeyboardDismisser({Key? key, required this.child}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Focus(
      // This helps intercept and handle keyboard events properly
      onKeyEvent: (FocusNode node, KeyEvent event) {
        // Let the framework handle the event normally
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
