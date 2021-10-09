import 'package:app/extensions.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/ui/home.dart';
import 'package:app/src/vm/question_vm.dart';
import 'package:app/src/vm/vm.dart';
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
          ],
        ),
      );
    });
  }
}
