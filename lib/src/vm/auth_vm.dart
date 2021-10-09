import 'package:app/async.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/resources/local_provider.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class AuthViewModel extends StreamViewModel {
  final Repository _repository;

  final name = Observable('');

  AuthViewModel(this._repository);

  Future<bool> googleAuth() => load(_repository.loginGoogle())
      .doOnData((value) => eventComplete(LocalProvider.event("4")!));

  Future<bool> anonAuth() => load(_repository.loginAnon(name.value))
      .doOnData((value) => eventComplete(LocalProvider.event("4")!));

  void eventComplete(Event event) {
    _repository.provider.currentPersonEvent(event: event);
  }
}
