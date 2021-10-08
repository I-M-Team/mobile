import 'package:app/extensions.dart';
import 'package:app/main.dart';
import 'package:app/src/ui/profile.dart';
import 'package:app/src/vm/profile_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/src/widgets/user_avatar.dart';
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
      appBar: AppBar(
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: Consumer<ProfileViewModel>(
              builder: (context, vm, child) => IconButton(
                icon: Observer(
                  builder: (context) => UserAvatar(
                    initials: vm.person.value?.nameOrEmail,
                    url: vm.person.value?.photoUrl,
                    radius: 16,
                  ),
                ),
                onPressed: () {
                  context.tryAuthorized(() => context.navigator
                      .pushPage((context) => ProfilePage.show()));
                },
              ),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.zero,
      child: null,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          context.tryAuthorized(() {
            context.scaffoldMessenger.showSnackBarError(text: 'NIY');
          });
        },
      ),
    );
  }
}
