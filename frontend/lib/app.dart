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
      title: 'Interna',
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
          seedColor: const Color(0xFF7678ED),
          primary: const Color(0xFF7678ED),
          onPrimary: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.1),
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.black87, size: 28),
        ),
        iconTheme: IconThemeData(color: const Color(0xFF7678ED), size: 26),
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
