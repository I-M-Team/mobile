import 'package:app/src/models/models.dart';
import 'package:app/src/models/person_models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class AddQuestionViewModel extends ViewModel {
  final Repository _repository;

  final Observable<Person?> person;

  AddQuestionViewModel(this._repository)
      : person = _repository.currentPerson().toObservable(null);

  void addQuestion(String content) =>
      _repository.createQuestion(
          content,
          content.split(' ').where((str) => str.startsWith('#')).toList()
      );
}
