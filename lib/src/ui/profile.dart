import 'package:app/extensions.dart';
import 'package:app/src/resources/local_provider.dart';
import 'package:app/src/vm/profile_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage._({Key? key}) : super(key: key);

  static Widget show() => ProfilePage._();

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends ViewModelState<ProfileViewModel, ProfilePage> {
  Widget build(BuildContext context) {
    return FullScreen(
      padding: EdgeInsets.only(bottom: context.theme.bottomInset),
      appBar: AppBar(elevation: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // todo add my questions
          // todo add my answers
          Observer(builder: (context) {
            return Material(
              elevation: 6,
              color: context.theme.colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                            children: [
                              Text("Мой уровень"),
                              Text(vm.getLevel().name),
                            ]
                        ),
                      ),
                      Expanded(
                        child: Column(
                            children: [
                              Text("Вопросов"),
                              Text("5"),
                            ]
                        ),
                      ),
                      Expanded(
                        child: Column(
                            children: [
                              Text("Ответов"),
                              Text("10"),
                            ]
                        ),
                      )
                    ]
                ),
              ),
            );
          }),
          Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.all(14)),
              onPressed: () => vm.logout(),
              icon: Icon(Icons.logout),
              label: Text(
                'Logout'.orDefault(),
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
