import 'package:app/src/models/models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class AddAnswerViewModel extends ViewModel {
  final Repository _repository;
  final Question target;
  final content = Observable('');

  AddAnswerViewModel(this._repository, this.target);

  void create() => _repository.createAnswer(target, content.value);
}
