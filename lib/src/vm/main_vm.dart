import 'dart:async';

import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class MainViewModel extends ViewModel {
  final Repository _repository;

  Future<bool> get isAuthorized => _repository.isAuthorized;

  Stream<bool> get authorized => _repository.authorized;

  MainViewModel(this._repository);
}
