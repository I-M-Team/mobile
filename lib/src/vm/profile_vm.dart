import 'package:app/async.dart';
import 'package:app/src/models/person_models.dart';
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
}
