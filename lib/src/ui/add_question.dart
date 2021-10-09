import 'package:app/extensions.dart';
import 'package:app/src/vm/add_question_vm.dart';
import 'package:app/src/vm/vm.dart';
import 'package:app/widgets.dart';
import 'package:flutter/material.dart';

class AddQuestionPage extends StatefulWidget {
  AddQuestionPage._({Key? key}) : super(key: key);

  static Widget show() => AddQuestionPage._();

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends ViewModelState<AddQuestionViewModel, AddQuestionPage> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

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
              controller: textController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Задайте свой вопрос'
              ),
            ),
            Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(14)),
                onPressed: () {
                  vm.addQuestion(textController.text);
                  Navigator.pop(context);
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


