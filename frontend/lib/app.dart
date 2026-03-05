import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:schedule_management_frontend/ui/di/di_config.dart';
import 'package:schedule_management_frontend/ui/router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ShiftFlow',
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade700,
          onPrimary: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 24, // Increased from 22
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 28,
          ), // Increased icon size
        ),
        iconTheme: IconThemeData(color: Colors.blue.shade700, size: 26),
        textTheme: GoogleFonts.interTextTheme(
          const TextTheme(
            bodyLarge: TextStyle(fontSize: 20), // Increased from 18
            bodyMedium: TextStyle(fontSize: 18), // Increased from 16
            bodySmall: TextStyle(fontSize: 16), // Increased from 14
            titleLarge: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ), // Increased from 24
            titleMedium: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ), // Increased from 20
            titleSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ), // Increased from 18
          ),
        ),
      ),
      routerConfig: appRouter.config(),
    );
  }
}
