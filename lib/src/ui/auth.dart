import 'package:app/app_localizations.dart';
import 'package:app/extensions.dart';
import 'package:app/src/resources/images.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/auth_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  AuthPage._({Key? key}) : super(key: key);

  static Widget show() => Provider(
        create: (c) => AuthViewModel(c.read<Repository>()),
        child: AuthPage._(),
      );

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends ViewModelState<AuthViewModel, AuthPage> {
  Widget build(BuildContext context) {
    return FullScreen(
      padding: EdgeInsets.zero,
      resizeToAvoidBottomInset: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.ac_unit, size: 60),
          _buildSocialButton(
            icon: Image(image: IconAssets.google),
            title: context.strings.googleAuth,
            onTap: _login(vm.googleAuth),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
      {required Widget icon, required String title, void onTap()?}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 20.0, left: 16, right: 16),
      child: Observer(
        builder: (context) => OutlinedButton.icon(
          style: ElevatedButton.styleFrom(padding: EdgeInsets.all(14)),
          onPressed: vm.loading.value ? null : onTap,
          icon: icon,
          label: Text(
            title.orDefault(),
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Function() _login(Future<bool> auth()) => () async {
        context.focusScope.hideKeyboard();
        if (await auth()) {
          context.navigator.pop(true);
        }
      };
}
