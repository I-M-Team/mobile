import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class AuthViewModel extends StreamViewModel {
  final Repository _repository;

  final name = Observable('');

  AuthViewModel(this._repository);

  Future<bool> googleAuth() => load(_repository.loginGoogle());

  Future<bool> anonAuth() => load(_repository.loginAnon(name.value));
}
