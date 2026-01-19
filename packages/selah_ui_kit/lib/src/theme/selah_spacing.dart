/// Selah spacing tokens
class SelahSpacing {
  SelahSpacing._();

  // Base spacing unit (4dp)
  static const double unit = 4.0;

  // Spacing scale
  static const double xxs = unit;       // 4
  static const double xs = unit * 2;    // 8
  static const double sm = unit * 3;    // 12
  static const double md = unit * 4;    // 16
  static const double lg = unit * 6;    // 24
  static const double xl = unit * 8;    // 32
  static const double xxl = unit * 12;  // 48
  static const double xxxl = unit * 16; // 64

  // Specific use cases
  static const double cardPadding = 16;
  static const double screenPadding = 20;
  static const double sectionGap = 24;
  static const double itemGap = 12;

  // Border radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;
}
