import 'package:flutter/material.dart';
import 'app_colors.dart';

const kMainGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [AppColors.purple, AppColors.teal],
);

const kBgGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF07071A), Color(0xFF061A22)],
);

TextStyle kH1(BuildContext c) => const TextStyle(
  fontSize: 36,
  height: 1.05,
  fontWeight: FontWeight.w800,
  color: AppColors.text,
  letterSpacing: -0.5,
  fontFamily: 'Nunito',
);

TextStyle kH2(BuildContext c) => const TextStyle(
  fontSize: 28,
  height: 1.08,
  fontWeight: FontWeight.w800,
  color: AppColors.text,
  letterSpacing: -0.3,
  fontFamily: 'Nunito',
);

TextStyle kBody(BuildContext c) => const TextStyle(
  fontSize: 14,
  height: 1.35,
  fontWeight: FontWeight.w500,
  color: AppColors.sub,
  fontFamily: 'Nunito',
);