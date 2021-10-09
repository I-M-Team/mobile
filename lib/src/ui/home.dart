import 'package:app/extensions.dart';
import 'package:app/main.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/resources/local_provider.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/ui/profile.dart';
import 'package:app/src/ui/question.dart';
import 'package:app/src/ui/rating.dart';
import 'package:app/src/vm/home_vm.dart';
import 'package:app/src/vm/profile_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/src/widgets/user_avatar.dart';
import 'package:app/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int _currentPage = 0;

  late List<ReactionDisposer> _disposers;

  @override
  void initState() {
    super.initState();

    _disposers = [
      reaction(
          (p0) => context
              .read<ProfileViewModel>()
              .person
              .value
              ?.getNextLevelEvent(), (Event? nextLevelEvent) {
        print('nextLevelEvent=${nextLevelEvent?.name}');
        nextLevelEvent?.also((item) async {
          await showDialog(
            context: context,
            builder: (context) => Dialog(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: CachedNetworkImage(
                        imageBuilder: (context, imageProvider) => Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: context.theme.dividerColor,
                        ),
                        imageUrl: item.icon,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${item.name}',
                      style: context.theme.textTheme.headline6,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${item.content}',
                      style: context.theme.textTheme.subtitle1,
                    ),
                  ],
                ),
              ),
            ),
          );
          print("alert closed");
          if (["3"].contains(item.id)) {
            vm.eventComplete(item);
          }
        });
      }),
    ];
  }

  @override
  void dispose() {
    _disposers.disposeAll();
    super.dispose();
  }

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
      child: whenValue(_currentPage, {
        0: buildQuestions,
        1: buildMissions,
        2: buildLeaderboard,
      }),
      floatingActionButton: _currentPage != 0
          ? null
          : FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                context.tryAuthorized(() => context.navigator
                    .pushPage((context) => AddQuestionPage.show()));
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (i) => setState(() => _currentPage = i),
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.question_answer_outlined), label: 'Questions'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_task), label: 'Missions'),
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined), label: 'Leaderboard'),
        ],
      ),
    );
  }

  Widget buildQuestions() {
    return Observer(
      builder: (context) => ListView.builder(
        padding: EdgeInsets.only(top: 30),
        itemCount: vm.questions.value.length,
        itemBuilder: (context, index) => QuestionWidget(
          item: vm.questions.value[index],
          onTap: (item) {
            context.navigator.pushPage((context) => QuestionPage.show(item));
          },
          action: (item, a) {
            context.tryAuthorized(() {
              // todo requery a after login
              if (a == Availability.not_acted) {
                vm.reaction(item);
              } else {
                vm.removeReaction(item);
              }
            });
          },
        ),
      ),
    );
  }

  Widget buildMissions() {
    vm.openedMissions();
    return MissionsSection();
  }

  Widget buildLeaderboard() {
    return RatingPage.show();
  }
}

class MissionsSection extends StatefulWidget {
  const MissionsSection({Key? key}) : super(key: key);

  @override
  _MissionsSectionState createState() => _MissionsSectionState();
}

class _MissionsSectionState
    extends ViewModelState<ProfileViewModel, MissionsSection> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 30),
      itemBuilder: (context, index) =>
          buildItem(LocalProvider.visibleEvents[index]),
      itemCount: LocalProvider.visibleEvents.size,
    );
  }

  Widget buildItem(Event item) {
    var enabled =
        (vm.person.value?.getNextLevel()?.events.contains(item.id)).orDefault();
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Card(
          child: Observer(
            builder: (context) {
              var isComplete =
                  (vm.person.value?.isEventComplete(item)).orDefault();
              return InkWell(
                onTap: item.link.isEmpty || !enabled || isComplete
                    ? null
                    : () async {
                        launch(item.link);
                        vm.eventComplete(item);
                      },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      foregroundDecoration: isComplete
                          ? BoxDecoration(color: Colors.white.withOpacity(0.8))
                          : null,
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                UserAvatar(
                                  radius: 40,
                                  url: item.icon,
                                  initials: '-',
                                  showHolder: false,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${item.name}',
                                        style:
                                            context.theme.textTheme.headline6,
                                      ),
                                      Text('${item.content}'),
                                      Text('${item.award} Баллов'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              (LocalProvider.levels
                                      .find((e) => e.events.contains(item.id))
                                      ?.name)
                                  .orDefault(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isComplete)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download_done_rounded,
                            color: Colors.lightGreen,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Завершено',
                            style: context.theme.textTheme.headline6
                                ?.copyWith(color: Colors.green),
                          ),
                        ],
                      )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final Question item;
  final void Function(Question item)? onTap;
  final void Function(Question item, Availability a) action;

  const QuestionWidget(
      {Key? key, required this.item, required this.action, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Card(
        child: InkWell(
          onTap: () => onTap?.call(item),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Observer(
              builder: (context) => Row(
                children: [
                  Expanded(
                    child: Column(
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
                                    (item.person().value?.getLevel().name)
                                        .orDefault(),
                                    style: context.theme.textTheme.caption,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        SizedBox(
                          width: double.infinity,
                          child: Text(item.content),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: item.availability().value == Availability.owner
                        ? null
                        : () => action(item, item.availability().value),
                    icon: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.availability().value != Availability.acted
                              ? Icons.thumb_up_outlined
                              : Icons.thumb_up,
                        ),
                        if (item.reactionCount().value > 0)
                          Text(
                            '${item.reactionCount().value}',
                            style: context.theme.textTheme.caption,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
