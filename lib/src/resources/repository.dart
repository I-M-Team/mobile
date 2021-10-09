import 'package:app/async.dart';
import 'package:app/extensions.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/models/person_models.dart';
import 'package:app/src/resources/firebase_provider.dart';
import 'package:rxdart/rxdart.dart';

class Repository {
  final provider = FirebaseProvider();

  Repository() {}

  Future<bool> get isAuthorized => provider.isAuthorized().firstElementFuture();

  Stream<bool> get authorized => provider.isAuthorized();

  Stream<bool> loginGoogle() => provider
      .signInGoogle()
      .then((value) => true)
      .asStream()
      .onErrorReturnWith(
          (error, stackTrace) => error is AuthCanceled ? false : throw error);

  Stream<bool> loginAnon(String name) => provider
      .signInAnon(name)
      .then((value) => true)
      .asStream()
      .onErrorReturnWith(
          (error, stackTrace) => error is AuthCanceled ? false : throw error);

  Stream<Person?> currentPerson() => provider.currentPerson();

  void logout() => provider.signOut();

  void createQuestion(String content) => provider.currentPersonPath?.let((it) =>
      provider.upsertQuestion(Question.create(it, content,
          content.split(' ').filter((str) => str.startsWith('#')))));

  Stream<List<Question>> questions() => provider.questions();

  void createAnswer(Question target, String content) =>
      provider.currentPersonPath?.let((it) => provider.upsertAnswer(
          target,
          Answer.create(it, content,
              content.split(' ').filter((str) => str.startsWith('#')))));
}
