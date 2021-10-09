import 'package:app/extensions.dart';
import 'package:app/main.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/ui/profile.dart';
import 'package:app/src/vm/home_vm.dart';
import 'package:app/src/vm/profile_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/src/widgets/user_avatar.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

import 'add_question.dart';

class HomePage extends StatefulWidget {
  HomePage._({Key? key}) : super(key: key);

  static Widget show() => Provider(
        create: (c) => HomeViewModel(c.read<Repository>()),
        child: HomePage._(),
      );

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ViewModelState<HomeViewModel, HomePage> {
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
      child: Observer(builder: (context) {
        return ListView.builder(
          itemCount: vm.questions.value.length,
          itemBuilder: (context, index) =>
              _buildHomeItem(context, vm.questions.value[index]),
        );
      }),
      floatingActionButton: Consumer<ProfileViewModel>(
        builder: (context, vm, child) => FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            context.tryAuthorized(() => context.navigator
                .pushPage((context) => AddQuestionPage.show()));
          },
        ),
      ),
    );
  }

  Widget _buildHomeItem(BuildContext context, Question item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Card(
        child: InkWell(
          onTap: () {},
          child: Observer(
              builder: (context) => ListTile(
                    trailing:
                        item.availability().value == Availability.unavailable
                            ? null
                            : IconButton(
                                onPressed: () {
                                  if (item.availability().value ==
                                      Availability.available) {
                                    vm.reaction(item);
                                  } else {
                                    vm.removeReaction(item);
                                  }
                                },
                                icon: Icon(
                                  item.availability().value ==
                                          Availability.available
                                      ? Icons.thumb_up_outlined
                                      : Icons.thumb_up,
                                ),
                              ),
                    title: Column(
                      children: <Widget>[
                        Observer(
                          builder: (context) => Row(
                            children: [
                              UserAvatar(
                                initials: item.person().value?.nameOrEmail,
                                url: item.person().value?.photoUrl,
                                radius: 16,
                              ),
                              SizedBox(width: 8.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((item.person().value?.nameOrEmail)
                                      .orDefault()),
                                  Text(
                                    (item.person().value?.level).orDefault(),
                                    style: context.theme.textTheme.caption,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(item.content),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  )),
        ),
      ),
    );
  }
}
