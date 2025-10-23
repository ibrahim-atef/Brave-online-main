import 'package:flutter/material.dart';

/// Main Color - نظام ألوان منصة كلمني اشارة
Color mainColor() => const Color(0xff1E88E5); // أزرق سماوي - اللون الأساسي
Color white() => Colors.black; // Second Color
Color gold() => const Color(0xffFF9800);

/// برتقالي - للأزرار
Color blue64() => const Color(0xff0D47A1); // أزرق داكن
LinearGradient greenGradint() => LinearGradient(
  colors: [mainColor(), const Color(0xff42A5F5)],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
);

// use in drawer background color
Color green63 = const Color(0xff1E88E5);

// grey Shade
Color grey33 = const Color(0xff2F3133);
Color grey3A = const Color(0xff757575);
Color grey5E = const Color(0xff5E5E5E);
Color greyD0 = const Color(0xffABB7D0);
Color greyB2 = const Color(0xffA9AEB2);
Color greyA5 = const Color(0xffA5A5A5);
Color greyCF = const Color(0xffCFCFCF);
Color greyE7 = const Color(0xffE7E7E7);
Color greyF8 = const Color(0xffF8F8F8);
Color greyFA = const Color(0xffFAFAFA);
LinearGradient greyGradint = LinearGradient(
  colors: [Colors.black.withOpacity(.8), Colors.black.withOpacity(0)],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
);

// Semantics
Color red49 = const Color(0xffF44336); // أحمر للأخطاء
Color yellow29 = const Color(0xffFFB300); // أصفر ذهبي
Color orange50 = const Color(0xffFF9800); // برتقالي

// Semantics
Color green50 = const Color(0xff4CAF50); // أخضر للنجاح
Color green4B = const Color(0xff00897B);
Color green9D = const Color(0xff26A69A);

Color cyan50 = const Color(0xff26C6DA);
Color blueFE = const Color(0xff42A5F5); // أزرق فاتح
Color blueA4 = const Color(0xff1565C0); // أزرق غامق
Color yellow4C = const Color(0xffFFB300);

// Shadow
BoxShadow boxShadow(Color color, {int blur = 20, int y = 8, int x = 0}) {
  return BoxShadow(
    color: color,
    blurRadius: blur.toDouble(),
    offset: Offset(x.toDouble(), y.toDouble()),
  );
}
