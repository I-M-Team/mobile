import 'dart:io';

import 'package:app/extensions.dart';
import 'package:app/generated/l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

export 'generated/l10n.dart';

/// Localization works with Jet brains Plugin for Intl.
///
///
/// For add localized string:
///
/// 1) !!!! MAKE SURE APP FONT SUPPORTS NEW LANGUAGE !!!!
///
/// Add string in intl_en.arb, see examples in file.
///
/// For add another locale
///
/// copy intl_en.arb to intl_<locale>.arb
/// Edit strings in new file
/// Plugin will generate all necessary code automatically (sometimes needs save file (ctrl+s))
/// Or use command:
/// flutter pub global run intl_utils:generate
/// before this command you need activate intl_utils by:
/// flutter pub global activate intl_utils <version>
///
///
/// ---- IOS specific part ---
///
/// iOS applications define key application metadata, including supported locales,
/// in an Info.plist file that is built into the application bundle. To configure
/// the locales supported by your app, you’ll need to edit this file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file then,
/// in the Project Navigator, open the Info.plist file under the Runner project’s
/// Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select eLocalizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each locale
/// your application supports, add a new item and select the locale you wish to
/// add from the pop-up menu in the Value field. This list should be consistent
/// with the languages listed in the supportedLocales parameter.
///
/// Once all supported locales have been added, save the file.
///

extension ContextExtensions on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this);

  MaterialLocalizations get systemStrings => MaterialLocalizations.of(this);

  int get firstDayOfWeek => this
      .systemStrings
      .firstDayOfWeekIndex
      .let((it) => it % 7)
      .let((it) => (it == 0) ? DateTime.sunday : it);

  String weekDay(int weekday) => DateTime.fromMicrosecondsSinceEpoch(0)
      .let(((date) => date.subtract(Duration(days: date.weekday - weekday))))
      .let(DateFormat.EEEE().format);
}

extension LocalizationExtension on AppLocalizations {
  String formatDuration(Duration duration) {
    var result = <String>[];
    if (duration.inHours > 0) {
      result.add(duration.inHours.zeroPrefix(2));
    }
    var minutes = duration.inMinutes % 60;
    result.add(minutes.zeroPrefix(2));
    var seconds = duration.inSeconds % 60;
    result.add(seconds.zeroPrefix(2));
    return result.joinToString(separator: ':');
  }

  String formatTimezoneOffset(Duration duration) {
    var result = <int>[];
    result.add(duration.inHours);
    var minutes = duration.inMinutes % 60;
    if (minutes > 0) {
      result.add(minutes);
    }
    var sign = duration.inMilliseconds < 0 ? "-" : "+";
    return '$sign${result.joinToString(separator: ':')}';
  }

  String localizationByName(String name, {String? defaultValue}) {
    return Intl.message(
      defaultValue ?? name.capitalize(),
      name: name,
      desc: '',
      args: [],
    );
  }

  String? humanizeError(dynamic error) {
    error = error is DioError
        ? whenValue(error.type, {
            DioErrorType.other: () => error.error,
            DioErrorType.response: () =>
                (error as DioError).response?.statusCode == 404
                    ? notFound
                    : error.response?.data,
          })
        : error;
    if ((error is PlatformException || error is DioError) &&
        error.message != null) {
      return error.message;
    } else if (error is SocketException || error is HandshakeException) {
      return networkError;
    } else if (error == null) {
      return defaultSnackbarError;
    } else {
      return error.toString();
    }
  }
}
