import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Palette {
  static const Color primary = Colors.blue;
  static const Color brandPrimary = Color(0xFF1C3D93);
  static const Color background = Color(0xFFF5F5F7);
  static const Color cardBackground = Colors.white;
  static const Color textBody = Color(0xFF201F21);
  static const Color textSecondary = Color(0xFF656366);
  static const Color accent = Color(0xFF201F21);

  // Typography
  static final TextStyle h1 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textBody,
  );

  static final TextStyle p = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textBody,
  );

  static final TextStyle b2 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textBody,
  );
}
