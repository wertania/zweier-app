import 'package:flutter/material.dart';

/// Warm, soft palette: rose, peach and cream – a little love letter in colours.
class ZColors {
  static const rose = Color(0xFFE5677D);
  static const roseDark = Color(0xFFC94A63);
  static const peach = Color(0xFFFFB997);
  static const apricot = Color(0xFFFFE3D3);
  static const cream = Color(0xFFFFF7F2);
  static const blush = Color(0xFFFBE4E8);
  static const plum = Color(0xFF4B2E3E);
  static const plumSoft = Color(0xFF8A6B7A);
  static const sage = Color(0xFF9CC5A1);
  static const sky = Color(0xFFA9CBEA);
  static const lavender = Color(0xFFCDB8E8);

  static const loveGradient = LinearGradient(
    colors: [rose, peach],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: ZColors.rose,
    primary: ZColors.rose,
    secondary: ZColors.peach,
    surface: ZColors.cream,
    onSurface: ZColors.plum,
  );
  final rounded = RoundedRectangleBorder(borderRadius: BorderRadius.circular(22));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: ZColors.cream,
    textTheme: Typography.blackMountainView
        .apply(bodyColor: ZColors.plum, displayColor: ZColors.plum)
        .copyWith(
          headlineMedium: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800, color: ZColors.plum, letterSpacing: -0.5),
          titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ZColors.plum),
        ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ZColors.cream,
      foregroundColor: ZColors.plum,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: ZColors.plum),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: rounded,
      margin: EdgeInsets.zero,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: ZColors.blush,
      side: const BorderSide(color: ZColors.blush),
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(color: ZColors.plum, fontWeight: FontWeight.w600),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ZColors.rose,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: ZColors.rose,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ZColors.blush, width: 1.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: ZColors.rose, width: 2)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: ZColors.blush,
      elevation: 0,
      labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: ZColors.plum)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: ZColors.cream,
      showDragHandle: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
  );
}
