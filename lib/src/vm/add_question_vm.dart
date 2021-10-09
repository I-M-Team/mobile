import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class AddQuestionViewModel extends ViewModel {
  final Repository _repository;

  final content = Observable('');

  AddQuestionViewModel(this._repository);

  void create() => _repository.createQuestion(content.value);
}
