import 'package:app/extensions.dart';
import 'package:app/main.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/ui/add_answer.dart';
import 'package:app/src/ui/home.dart';
import 'package:app/src/vm/question_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/src/widgets/user_avatar.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class QuestionPage extends StatefulWidget {
  QuestionPage._({Key? key}) : super(key: key);

  static Widget show(Question item) => Provider(
        create: (c) => QuestionViewModel(c.read<Repository>(), item),
        child: QuestionPage._(),
      );

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState
    extends ViewModelState<QuestionViewModel, QuestionPage> {
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return FullScreen(
        appBar: AppBar(elevation: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              elevation: 6,
              color: context.theme.colorScheme.primary,
              child: QuestionWidget(
                item: vm.item.value,
                action: (item, a) {
                  if (a == Availability.available) {
                    vm.reaction(item);
                  } else {
                    vm.removeReaction(item);
                  }
                },
              ),
            ),
            SizedBox(height: 26),
            Expanded(
              child: Observer(
                builder: (context) => ListView.builder(
                  itemCount: vm.answers.value.length,
                  itemBuilder: (context, index) => AnswerWidget(
                    item: vm.answers.value[index],
                    action: (item, a) {
                      if (a == Availability.available) {
                        vm.reaction(item);
                      } else {
                        vm.removeReaction(item);
                      }
                    },
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.question_answer_outlined),
          onPressed: () {
            context.tryAuthorized(() => context.navigator
                .pushPage((context) => AddAnswerPage.show(vm.item.value)));
          },
        ),
      );
    });
  }
}

class AnswerWidget extends StatelessWidget {
  final Answer item;
  final void Function(Answer item, Availability a) action;

  const AnswerWidget({Key? key, required this.item, required this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: InkWell(
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
                                    (item.person().value?.level).orDefault(),
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
                        SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: item.availability().value ==
                                Availability.unavailable
                            ? null
                            : () => action(item, item.availability().value),
                        icon: Icon(
                          item.availability().value !=
                                  Availability.available_negation
                              ? Icons.thumb_up_outlined
                              : Icons.thumb_up,
                        ),
                      ),
                      if (item.reactionCount().value > 0)
                        Text(
                          '${item.reactionCount().value}',
                          style: context.theme.textTheme.caption,
                        ),
                    ],
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
