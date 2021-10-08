import 'package:app/extensions.dart';
import 'package:app/main.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ViewModelState<MainViewModel, HomePage> {
  Widget build(BuildContext context) {
    return FullScreen(
      child: null,
      floatingActionButton: FloatingActionButton(onPressed: () {
        context.tryAuthorized(() {
          context.scaffoldMessenger.showSnackBarError(text: 'NIY');
        });
      }),
    );
  }
}
