import 'package:app/extensions.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/add_question_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class AddQuestionPage extends StatefulWidget {
  AddQuestionPage._({Key? key}) : super(key: key);

  static Widget show() => Provider(
        create: (c) => AddQuestionViewModel(c.read<Repository>()),
        child: AddQuestionPage._(),
      );

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState
    extends ViewModelState<AddQuestionViewModel, AddQuestionPage> {
  Widget build(BuildContext context) {
    return FullScreen(
      padding: EdgeInsets.only(bottom: context.theme.bottomInset),
      appBar: AppBar(
        title: Text("Новый вопрос".orDefault()),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            TextFormField(
              initialValue: vm.content.value,
              onChanged: (value) => vm.content.set(value),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Задайте свой вопрос'),
            ),
            Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(14)),
                onPressed: () {
                  vm.create();
                  context.navigator.pop();
                },
                icon: Icon(Icons.add),
                label: Text(
                  'Отправить вопрос'.orDefault(),
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
