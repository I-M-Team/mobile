import 'package:app/src/models/models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class AddAnswerViewModel extends ViewModel {
  final Repository _repository;
  final Question target;
  // final Observable<Answer?> answer;
  final content = Observable('');

  AddAnswerViewModel(this._repository, this.target)
  /*: answer =
            _repository.provider.currentPersonAnswer(target).toObservable(null)*/
  ;

  void create() {
    _repository.createAnswer(target, content.value);
  }
}
