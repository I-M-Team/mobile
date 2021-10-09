import 'dart:async';

import 'package:app/app_localizations.dart';
import 'package:app/async.dart';
import 'package:app/extensions.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/ui/auth.dart';
import 'package:app/src/ui/home.dart';
import 'package:app/src/vm/add_question_vm.dart';
import 'package:app/src/vm/profile_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  var repository = Repository();
  runApp(MultiProvider(
    providers: [
      Provider.value(value: repository),
      Provider(create: (c) => MainViewModel(repository)),
      Provider(create: (c) => ProfileViewModel(repository)),
      Provider(create: (c) => AddQuestionViewModel(repository)),
    ],
    child: App(),
  ));
}

class App extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<App> createState() => _AppState();
}

class _AppState extends ViewModelState<MainViewModel, App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  late List<StreamSubscription> _disposers;

  @override
  void initState() {
    super.initState();

    _disposers = [
      vm.authorized.listen((value) {
        printLog(() => 'authorized=$value');
        if (!value) {
          try {
            _navigatorKey.currentState?.popUntil((route) => route.isFirst);
          } catch (e) {
            printLog(() => e);
          }
        }
      }),
    ];
  }

  @override
  void dispose() {
    _disposers.cancelAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'MoreTech',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage.show(),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
    );
  }
}

extension ContextExtension on BuildContext {
  Future<T?> tryAuthorized<T>(
    FutureOr<T?> authorized(),
  ) async {
    if (await this.read<MainViewModel>().isAuthorized) {
      return authorized();
    } else {
      bool? signedIn = await this
          .navigator
          .pushPage((context) => AuthPage.show(), fullscreenDialog: true);
      if (signedIn == true) {
        return authorized();
      } else {
        return null;
      }
    }
  }
}
