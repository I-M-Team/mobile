import 'package:app/src/models/models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class QuestionViewModel extends StreamViewModel {
  final Repository _repository;

  final Observable<Question> item;

  final Observable<List<Answer>> answers;

  final Observable<bool> isAnswerAvailable;

  late final Computed<bool> isAcceptAvailable;

  QuestionViewModel(this._repository, Question item)
      : item = _repository.provider.question(item.path).toObservable(item),
        answers = _repository.provider.answers(item).toObservable([]),
        isAnswerAvailable = _repository.provider
            .isAnswerAvailable(item)
            .map((event) => Availability.not_acted == event)
            .toObservable(false) {
    isAcceptAvailable = Computed(() =>
        item.availability().value == Availability.owner &&
        answers.value.every((e) => !e.accepted));
  }

  void reaction(Reactionable item) => _repository.provider.createReaction(item);

  void removeReaction(Reactionable item) =>
      _repository.provider.removeReaction(item);

  void toggleAccept(Answer item) {
    _repository.provider.acceptAnswer(item, !item.accepted);
  }
}
