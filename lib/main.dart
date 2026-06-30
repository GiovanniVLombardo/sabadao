import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:sabadao/auth/auth_gate.dart';
import 'package:sabadao/controllers/attendance_controller.dart';
import 'package:sabadao/controllers/match_controller.dart';
import 'package:sabadao/controllers/scout_controller.dart';
import 'package:sabadao/controllers/team_controller.dart';
import 'package:sabadao/controllers/user_controller.dart';
import 'package:sabadao/screens/ranking/ranking_screen.dart';
import 'package:sabadao/screens/settings/settings_screen.dart';
import 'package:sabadao/theme/app_theme.dart';
import 'package:sabadao/utils/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
      url: dotenv.env["SUPABASE_APP_URL"] ?? '',
      publishableKey: dotenv.env["SUPABASE_APP_KEY"] ?? '',
    );
    await initializeDateFormatting(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => MatchController()),
        ChangeNotifierProvider(create: (_) => AttendanceController()),
        ChangeNotifierProvider(create: (_) => ScoutController()),
        ChangeNotifierProvider(create: (_) => TeamController()),
      ],
      child: MaterialApp(
        title: 'Sabadão F. C.',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: AppTheme.darkTheme,
        routes: {
          AppRoutes.home : (context) => const AuthGate(),
          AppRoutes.ranking: (context) => const RankingScreen(),
          AppRoutes.settings: (context) => const SettingsScreen()
        },
      ),
    );
  }
}
