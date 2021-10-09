import 'package:flutter/widgets.dart';

abstract class VtbColors {
  static const Color blue10 = Color.fromRGBO(235, 243, 254, 1.0);
  static const Color blue20 = Color.fromRGBO(216, 230, 252, 1.0);
  static const Color blue30 = Color.fromRGBO(176, 205, 249, 1.0);
  static const Color blue40 = Color.fromRGBO(137, 181, 247, 1.0);
  static const Color blue50 = Color.fromRGBO(98, 156, 244, 1.0);
  static const Color blue60 = Color.fromRGBO(58, 131, 241, 0.3);
  static const Color blue70 = Color.fromRGBO(49, 111, 204, 1.0);
  static const Color blue80 = Color.fromRGBO(34, 80, 148, 1.0);
  static const Color blue90 = Color.fromRGBO(20, 49, 92, 1.0);
  static const Color blue100 = Color.fromRGBO(11, 29, 55, 1.0);

  static const Color textColor = Color.fromRGBO(33, 36, 44, 1.0);
}

abstract class VtbColorsDark {
  static const Color blue10 = Color.fromRGBO(23, 32, 48, 1.0);
  static const Color blue20 = Color.fromRGBO(27, 43, 70, 1.0);
  static const Color blue30 = Color.fromRGBO(35, 65, 113, 1.0);
  static const Color blue40 = Color.fromRGBO(43, 87, 155, 1.0);
  static const Color blue50 = Color.fromRGBO(50, 109, 198, 1.0);
  static const Color blue60 = Color.fromRGBO(58, 131, 241, 0.3);
  static const Color blue70 = Color.fromRGBO(92, 151, 241, 1.0);
  static const Color blue80 = Color.fromRGBO(126, 171, 240, 1.0);
  static const Color blue90 = Color.fromRGBO(160, 192, 239, 1.0);
  static const Color blue100 = Color.fromRGBO(194, 212, 239, 1.0);
}

abstract class VtbStyles {
  static const TextStyle largeTitle1 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 32,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal
  );

  static const TextStyle largeTitle2 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 32,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal
  );

  static const TextStyle title1 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 22,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold
  );

  static const TextStyle title2 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 22,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500
  );

  static const TextStyle subtitle1 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 18,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold
  );

  static const TextStyle subtitle2 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 18,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600
  );

  static const TextStyle subtitle3 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 18,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal
  );

  static const TextStyle headline = TextStyle(
      color: VtbColors.textColor,
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600
  );

  static const TextStyle body1 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500
  );

  static const TextStyle body2 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal
  );

  static const TextStyle subhead1 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 14,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.bold
  );

  static const TextStyle subhead2 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 14,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w600
  );

  static const TextStyle subhead3 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 14,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500
  );

  static const TextStyle subhead4 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 14,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal
  );

  static const TextStyle caption1 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 12,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500
  );

  static const TextStyle caption2 = TextStyle(
      color: VtbColors.textColor,
      fontSize: 10,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500
  );
}