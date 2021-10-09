import 'package:app/async.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/models/person_models.dart';
import 'package:app/src/resources/local_provider.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class ProfileViewModel extends ViewModel {
  final Repository _repository;

  final Observable<Person?> person;

  late final Observable<int> answersCount;

  ProfileViewModel(this._repository)
      : person = _repository.currentPerson().toObservable(null) {
    answersCount = person
        .toStream()
        .flatMapUntilNext((value) => value == null
            ? Stream.value(0)
            : _repository.provider.personAnswersCount(value))
        .toObservable(0);
  }

  void logout() => _repository.logout();

  Level getLevel() {
    List<String> personEvents = [];
    var progress = person.value?.eventsProgress ?? {};
    for (var event in LocalProvider.events) {
      if (progress[event.id] == event.conditions) {
        personEvents.add(event.id);
      }
    }

    Level personLevel = LocalProvider.levels.first;
    for (var level in LocalProvider.levels.reversed) {
      if (level.events == personEvents) {
        personLevel = level;
      }
    }

    return personLevel;
  }
}
