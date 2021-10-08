import 'dart:async';

import 'package:app/app_localizations.dart';
import 'package:app/async.dart';
import 'package:app/extensions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

extension SnackbarExtension on ScaffoldMessengerState {
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarText(
          String text,
          {Duration duration = const Duration(seconds: 1)}) =>
      showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(text),
        duration: duration,
      ));

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBarError({
    String? text,
    dynamic error,
    void onAction()?,
    void onClosed()?,
  }) {
    if (error is Error) {
      printLog(() => 'snackBarError=${error.stackTrace}');
    } else {
      printLog(() =>
          'snackBarError=${error?.toString() ?? text ?? 'Failed to complete action'}');
    }
    var data = text ?? this.context.strings.humanizeError(error)!;

    removeCurrentSnackBar();
    var snackBar = showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        data,
        // style: TextStyle(color: Colors.white),
      ),
      action: SnackBarAction(
        label: context.strings.ok.toUpperCase(),
        onPressed: onAction ?? () {},
      ),
      duration: Duration(minutes: 4),
    ));

    if (onClosed != null) {
      snackBar.closed.then(
          (value) => value == SnackBarClosedReason.hide ? null : onClosed());
    }
    return snackBar;
  }
}

extension RouteExtension on NavigatorState {
  Future<T?> pushPage<T>(WidgetBuilder builder, {fullscreenDialog: false}) =>
      this.push(MaterialPageRoute(
          builder: builder, fullscreenDialog: fullscreenDialog));
}

// mixin PageActiveMixin<T extends StatefulWidget> on State<T>
//     implements RouteAware {
//   final _subject = BehaviorSubject.seeded(false);
//   var routeObserver;
//
//   Stream<bool> get isPageActive => _subject;
//
//   bool active = false;
//
//   @override
//   void initState() {
//     super.initState();
//     routeObserver = context.appState.routeObserver;
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     routeObserver.subscribe(this, context.modalRoute);
//   }
//
//   @override
//   void dispose() {
//     _subject.close();
//     routeObserver.unsubscribe(this);
//     super.dispose();
//   }
//
//   @override
//   void didPush() => onActive();
//
//   @override
//   void didPopNext() => onActive();
//
//   @override
//   void didPop() => onInactive();
//
//   @override
//   void didPushNext() => onInactive();
//
//   void onActive() {
//     active = true;
//     _subject.add(true);
//   }
//
//   void onInactive() {
//     active = false;
//     _subject.add(false);
//   }
// }

mixin InitStateWithContextMixin<T extends StatefulWidget> on State<T> {
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      _init = true;
      initContextDependentState(context);
    }
  }

  @protected
  void initContextDependentState(BuildContext context);

  @override
  void dispose() {
    super.dispose();
    _init = false;
  }
}

class InitState extends StatefulWidget {
  final void Function(BuildContext context)? init;
  final void Function(BuildContext context)? dispose;
  final Widget child;

  const InitState({Key? key, this.init, this.dispose, required this.child})
      : super(key: key);

  @override
  _InitStateState createState() => _InitStateState();
}

class _InitStateState extends State<InitState> {
  @override
  void initState() {
    super.initState();
    if (widget.init != null) {
      widget.init!(context);
    }
  }

  @override
  void dispose() {
    if (widget.dispose != null) {
      widget.dispose!(context);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class FullScreen extends StatelessWidget {
  final Widget? child;

  final PreferredSizeWidget? appBar;

  final Widget? bottomNavigationBar;

  final Widget? floatingActionButton;

  final EdgeInsetsGeometry? padding;

  final bool resizeToAvoidBottomInset;

  final bool extendBody;

  final bool extendBodyBehindAppBar;

  final bool extendBodyBehindStatusBar;

  final Color? backgroundColor;

  FullScreen({
    Key? key,
    this.appBar,
    required this.child,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.padding,
    this.resizeToAvoidBottomInset = true,
    this.extendBodyBehindAppBar = false,
    this.extendBodyBehindStatusBar = false,
    this.extendBody = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => context.focusScope.hideKeyboard(),
      child: Scaffold(
        appBar: appBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        body: SafeArea(
          top: !extendBodyBehindStatusBar,
          bottom: false,
          child: Padding(
            padding: padding ??
                EdgeInsets
                    .zero /*
                (bottomNavigationBar == null
                    ? EdgeInsets.only(bottom: context.theme.bottomInset)
                    : EdgeInsets.zero)*/
            ,
            child: child,
          ),
        ),
        backgroundColor: backgroundColor,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }
}

extension ThemeDataExtensions on ThemeData {
  double get bottomInset {
    return 30.0;
  }
}

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final TextStyle? textStyle;
  final bool enabled;

  const DialogButton.borderless({
    Key? key,
    required this.text,
    this.onPressed,
    this.onLongPress,
    this.textStyle,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var buttonTheme = context.theme.textTheme.button
        ?.copyWith(color: context.theme.accentColor);
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: (textStyle == null
                  ? buttonTheme
                  : buttonTheme?.merge(textStyle))
              ?.copyWith(
                  color: enabled && (onPressed != null || onLongPress != null)
                      ? null
                      : context.theme.disabledColor),
        ),
      ),
      onTap: enabled ? onPressed : null,
      onLongPress: enabled ? onLongPress : null,
    );
  }
}

class ScrollingEmptyHolder extends StatelessWidget {
  final String title;

  const ScrollingEmptyHolder({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            title,
            style: context.theme.textTheme.subtitle2,
          ),
        ),
      ),
    );
  }
}

class CircleActionButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double size;
  final bool enabled;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const CircleActionButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.onLongPress,
    this.size = 60,
    this.enabled = true,
    this.foregroundColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;

    final foregroundColor = this.foregroundColor ??
        floatingActionButtonTheme.foregroundColor ??
        theme.colorScheme.onSecondary;
    final textStyle = theme.textTheme.button?.copyWith(
      color: foregroundColor,
      letterSpacing: 1.2,
    );

    return Container(
      width: size,
      height: size,
      child: RawMaterialButton(
        shape: CircleBorder(),
        elevation: 6.0,
        child: icon,
        textStyle: textStyle,
        fillColor: backgroundColor ?? context.theme.accentColor,
        onPressed: enabled ? onPressed : null,
        onLongPress: enabled ? onLongPress : null,
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final double size;
  final String? initials;
  final String? imageUrl;

  const Avatar({
    Key? key,
    required this.size,
    this.initials,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        image: imageUrl?.let(((it) => DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(it),
            ))),
      ),
      child: initials == null
          ? null
          : Text(
              (initials?.let(((it) =>
                      it.toUpperCase().substring(0, min(2, it.length)))))
                  .orDefault(),
              style: context.theme.textTheme.subtitle2
                  ?.copyWith(color: context.theme.textTheme.caption?.color),
            ),
    );
  }
}

class TitledSwitch extends StatelessWidget {
  final String title;

  final bool value;

  final void Function(bool value) onChanged;

  const TitledSwitch({
    Key? key,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: context.theme.textTheme.button?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CupertinoSwitch(
              value: value,
              onChanged: onChanged,
              activeColor: context.theme.accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// An indicator showing the currently selected page of a PageController
class LineIndicator extends AnimatedWidget {
  LineIndicator({
    required this.controller,
    required this.itemCount,
    this.itemHeight: 4,
    this.itemSpace: 10,
    this.itemWidth,
    this.onPageSelected,
    this.color: Colors.white,
    this.selectedColor: Colors.black,
    this.steps: false,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  final bool steps;

  final double itemHeight;

  /// Called when a dot is tapped
  final ValueChanged<int>? onPageSelected;

  /// The color of the dots.
  ///
  /// Defaults to `Colors.white`.
  final Color color;

  final Color selectedColor;

  final double? itemWidth;

  // The distance between the center of each dot
  final double itemSpace;

  Widget _buildLine(int index) {
    var currentIndex = ((controller.hasClients ? controller.page : null) ??
            controller.initialPage)
        .round();
    bool selected = steps ? (index <= currentIndex) : currentIndex == index;

    // todo automatically calc width if null
    return _wrapWidth(
      Material(
        color: selected ? selectedColor : color,
        type: MaterialType.canvas,
        child: Container(
          width: itemWidth,
          height: itemHeight,
          child: InkWell(
            onTap: () => onPageSelected?.call(index),
          ),
        ),
      ),
    );
  }

  Widget _wrapWidth(Widget child) {
    return itemWidth == null ? Expanded(child: child) : child;
  }

  Widget build(BuildContext context) {
    return Container(
      height: itemHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(itemCount, _buildLine)
            .insertBetween((index) => SizedBox(width: itemSpace)),
      ),
    );
  }
}

class ColoredDot extends StatelessWidget {
  final Color? color;
  final Color? borderColor;
  final double size;
  final double thickness;
  final Widget? child;

  const ColoredDot({
    Key? key,
    this.color,
    required this.size,
    this.borderColor,
    this.thickness = 1.0,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: color ?? Colors.transparent,
        border:
            borderColor?.let((it) => Border.all(color: it, width: thickness)),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

class AlwaysNotFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;

  @override
  bool get hasPrimaryFocus => false;
}

class LoadingPage extends StatelessWidget {
  final String? title;

  LoadingPage.empty() : this.title = null;

  LoadingPage({this.title});

  LoadingPage.defaultStub(BuildContext context)
      : title = context.strings.loadingYourData;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: title == null
          ? Colors.transparent
          : context.theme.scaffoldBackgroundColor,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ColoredDot(
            size: 46,
            color: context.theme.scaffoldBackgroundColor,
            // borderColor: Colors.grey[200],
            // thickness: 1,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          if (title != null) SizedBox(height: 30),
          if (title != null)
            Text(
              title!,
              style: context.theme.textTheme.headline4,
            ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Color? color;

  const SectionTitle({
    Key? key,
    required this.title,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: color != Colors.white
                  ? BorderSide.none
                  : BorderSide(color: Color(0xffcacaca)),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            color: color ?? context.theme.accentColor,
          ),
          width: 6.0,
          height: 30,
        ),
        SizedBox(width: 20),
        Expanded(
          child: Text(
            title.orDefault().overflow,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.theme.textTheme.subtitle2,
          ),
        ),
      ],
    );
  }
}

abstract class LoadingState<T extends StatefulWidget> extends State<T> {
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool value) => setState(() {
        _loading = value;
      });

  @override
  Widget build(BuildContext context) {
    return loading ? loadingWidget(context) : buildWidget(context);
  }

  Widget loadingWidget(BuildContext context) {
    return LoadingPage.defaultStub(context);
  }

  @protected
  Widget buildWidget(BuildContext context);
}

mixin LoadingMixin<T extends StatefulWidget> on State<T> {
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool value) => setState(() {
        _loading = value;
      });

  String loadingTitle(BuildContext context) => context.strings.loadingYourData;

  @override
  Widget build(BuildContext context) {
    return loading ? loadingWidget(context) : buildWidget(context);
  }

  Widget loadingWidget(BuildContext context) {
    return LoadingPage(title: loadingTitle(context));
  }

  @protected
  Widget buildWidget(BuildContext context);
}

class ModalBottomSheetContainer extends StatelessWidget {
  final double? height;
  final Widget child;
  final List<Widget>? buttons;

  const ModalBottomSheetContainer({
    Key? key,
    this.height,
    required this.child,
    this.buttons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ...?buttons,
//                DialogButton.borderless(
//                  text: closeButtonText ?? context.strings.close,
//                  onPressed: () => context.navigator.maybePop(true),
//                )
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

Future<T?> showCupertinoDatePickerDialog<T>({
  required BuildContext context,
  required ValueChanged<DateTime> onDateTimeChanged,
  DateTime? initialDateTime,
  List<Widget>? buttons,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.time,
}) async {
  return showModalBottomSheet<T>(
    context: context,
    builder: (context) {
      return ModalBottomSheetContainer(
        height: 400,
        buttons: buttons,
//        closeButtonText: context.strings.done,
        child: CupertinoDatePicker(
          use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
          initialDateTime: initialDateTime,
          mode: mode,
          backgroundColor: context.theme.bottomSheetTheme.modalBackgroundColor,
          onDateTimeChanged: (value) {
            HapticFeedback.selectionClick();

            // [onDateTimeChanged] calls even if dialog is disappearing.
            //
            // But at the time 'finalize pick' (clear, done) button can be
            // pressed and this behavior is undesirable.
            //
            // For prevent this behavior here is filter that checks if current
            // dialog is on screen or disappearing.
            var isOnScreen = context.modalRoute?.animation?.status !=
                AnimationStatus.reverse;
            if (isOnScreen) onDateTimeChanged(value);
          },
        ),
      );
    },
  );
}

Future<T?> showCupertinoDurationPickerDialog<T>({
  required BuildContext context,
  required ValueChanged<Duration> onTimerDurationChanged,
  Duration initialDuration = Duration.zero,
  CupertinoTimerPickerMode mode: CupertinoTimerPickerMode.hm,
}) async {
  return showModalBottomSheet(
    context: context,
    builder: (context) {
      return ModalBottomSheetContainer(
        height: 300,
        child: CupertinoTimerPicker(
          initialTimerDuration: initialDuration,
          mode: mode,
          secondInterval: 5,
          backgroundColor: context.theme.bottomSheetTheme.modalBackgroundColor,
          alignment: Alignment.topCenter,
          onTimerDurationChanged: (value) {
            HapticFeedback.selectionClick();
            onTimerDurationChanged(value);
          },
        ),
      );
    },
  );
}
