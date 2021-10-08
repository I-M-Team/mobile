import 'package:app/src/models/person_models.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class ProfileViewModel extends ViewModel {
  final Repository _repository;

  final Observable<Person?> person;

  ProfileViewModel(this._repository)
      : person = _repository.currentPerson().toObservable(null);

  void logout() => _repository.logout();
}
