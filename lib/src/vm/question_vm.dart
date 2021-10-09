import 'package:app/src/models/models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class QuestionViewModel extends StreamViewModel {
  final Repository _repository;

  final Observable<Question> item;

  QuestionViewModel(this._repository, Question item)
      : item = _repository.provider.question(item.path).toObservable(item);

  void reaction(Reactionable item) => _repository.provider.createReaction(item);

  void removeReaction(Reactionable item) =>
      _repository.provider.removeReaction(item);
}
