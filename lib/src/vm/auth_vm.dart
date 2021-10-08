import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class AuthViewModel extends StreamViewModel {
  final Repository _repository;

  AuthViewModel(this._repository);

  Future<bool> googleAuth() => load(_repository.loginGoogle());
}
