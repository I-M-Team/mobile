import 'package:app/async.dart';
import 'package:app/src/resources/firebase_provider.dart';
import 'package:rxdart/rxdart.dart';

class Repository {
  final _provider = FirebaseProvider();

  Repository() {}

  Future<bool> get isAuthorized =>
      _provider.isAuthorized().firstElementFuture();

  Stream<bool> loginGoogle() => _provider
      .signInGoogle()
      .then((value) => true)
      .asStream()
      .onErrorReturnWith(
          (error, stackTrace) => error is AuthCanceled ? false : throw error);
}
