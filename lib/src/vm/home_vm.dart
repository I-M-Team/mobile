import 'package:app/src/models/models.dart';
import 'package:app/src/resources/local_provider.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class HomeViewModel extends StreamViewModel {
  final Repository _repository;

  late Observable<List<Question>> questions;

  HomeViewModel(this._repository) {
    questions = _repository.questions().toObservable([]);
  }

  void reaction(Reactionable item) => _repository.provider.createReaction(item);

  void removeReaction(Reactionable item) =>
      _repository.provider.removeReaction(item);

  void openedMissions() {
    eventComplete(LocalProvider.event("1")!);
  }

  void eventComplete(Event event) {
    _repository.provider.currentPersonEvent(event: event);
  }
}
