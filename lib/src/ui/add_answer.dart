import 'package:app/extensions.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/add_answer_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class AddAnswerPage extends StatefulWidget {
  AddAnswerPage._({Key? key}) : super(key: key);

  static Widget show(Question target) => Provider(
        create: (c) => AddAnswerViewModel(c.read<Repository>(), target),
        child: AddAnswerPage._(),
      );

  @override
  _AddAnswerPageState createState() => _AddAnswerPageState();
}

class _AddAnswerPageState
    extends ViewModelState<AddAnswerViewModel, AddAnswerPage> {
  Widget build(BuildContext context) {
    return FullScreen(
      padding: EdgeInsets.only(bottom: context.theme.bottomInset),
      appBar: AppBar(
        title: Text("Новый ответ".orDefault()),
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
                  border: UnderlineInputBorder(), labelText: 'Ответ'),
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
                  'Отправить'.orDefault(),
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
