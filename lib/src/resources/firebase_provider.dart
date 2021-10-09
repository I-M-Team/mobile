import 'package:app/async.dart';
import 'package:app/extensions.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/models/person_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseProvider {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn(
    scopes: [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/userinfo.profile",
    ],
  );
  static final _users = _collection('users');
  static final _questions = _collection('questions');

  static DocumentReference<Map<String, dynamic>> _doc(String path) =>
      FirebaseFirestore.instance.doc(path);

  static CollectionReference<Map<String, dynamic>> _collection(String path) =>
      FirebaseFirestore.instance.collection(path);

  static CollectionReference<Map<String, dynamic>> _answers(String path) =>
      _doc(path).collection('answers');

  static CollectionReference<Map<String, dynamic>> _reactions(String path) =>
      _doc(path).collection('reactions');

  String? get currentPersonId => _auth.currentUser?.uid;

  String? get currentPersonPath =>
      currentPersonId?.let((it) => _users.doc(it).path);

  Stream<bool> isAuthorized() => currentPerson().map((it) => it != null);

  Future<void> signInAnon(String name) async {
    var user = _auth.currentUser;
    if (user == null) {
      final result = await _auth.signInAnonymously();
      user = result.user;
      print("Signed in ${user?.uid}");
    } else {
      print("Already authed ${user.uid}");
    }

    if (user != null) {
      return createPerson(Person.create(
        'users/${user.uid}',
        name,
        '',
        '',
      ));
    } else {
      throw AuthCanceled();
    }
  }

  Future<void> signInGoogle() async {
    printLog(() => 'Starting google sign in');
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthCanceled();
    }

    printLog(() => 'Getting auth info');
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    printLog(() => 'Signing in');
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    printLog(() => "Signed in with google ${user?.uid}");

    if (user != null) {
      return createPerson(Person.create(
        'users/${user.uid}',
        googleUser.displayName.orDefault(),
        googleUser.email,
        googleUser.photoUrl.orDefault(),
      ));
    } else {
      throw AuthCanceled();
    }
  }

  Future<void> signOut() {
    return _googleSignIn
        .signOut()
        .then((_) => _auth.signOut())
        .then((_) => printLog(() => 'Signed Out!'));
  }

  Future<void> createPerson(Person person) {
    return _doc(person.path).set(person.toJson(), SetOptions(merge: true));
  }

  Stream<Person?> currentPerson() {
    return _auth.authStateChanges().flatMapUntilNext(
          (event) => event == null
              ? Stream.value(null)
              : _users.doc(event.uid).snapshots().map((json) => json
                  .takeIf((it) => it.exists)
                  ?.let((it) => Person.fromSnapshot(it))),
        );
  }

  static Stream<Person?> person(String path) {
    return _doc(path).snapshots().map((json) =>
        json.takeIf((it) => it.exists)?.let((it) => Person.fromSnapshot(it)));
  }

  Stream<Question> question(String path) {
    return _doc(path).snapshots().map((event) => Question.fromSnapshot(event));
  }

  Stream<List<Question>> questions() {
    return _questions
        .snapshots()
        .map((event) => event.docs.mapToList((e) => Question.fromSnapshot(e)));
  }

  Stream<List<Question>> questionsFor(String query) {
    return _questions
        .where('tickers', arrayContains: query)
        .snapshots()
        .map((event) => event.docs.mapToList((e) => Question.fromSnapshot(e)));
  }

  Future<void> upsertQuestion(Question item) {
    return item.path.isEmpty
        ? _questions.add(item.toJson())
        : _doc(item.path).set(item.toJson(), SetOptions(merge: true));
  }

  Stream<List<Answer>> answers(Question item) {
    return _answers(item.path)
        .orderBy('accepted', descending: true)
        .orderBy('created_at')
        .snapshots()
        .map((event) => event.docs.mapToList((e) => Answer.fromSnapshot(e)));
  }

  static Stream<Availability> isAnswerAvailable(Question item) {
    return _auth.authStateChanges().flatMapUntilNext((value) =>
        _doc(item.personPath).id == value?.uid
            ? Stream.value(Availability.owner)
            : _answers(item.path).doc(value?.uid).snapshots().map((event) =>
                event.exists
                    ? Availability.reacted
                    : Availability.not_reacted));
  }

  Future<void> upsertAnswer(Question question, Answer item) {
    // todo should use isAnswerAvailable before execution
    return item.path.isEmpty
        ? _answers(question.path).add(item.toJson())
        : _doc(item.path).set(item.toJson(), SetOptions(merge: true));
  }

  Future<void> remove(Doc item) {
    return _doc(item.path).delete();
  }

  Future<void> acceptAnswer(Answer item, bool value) {
    // todo should check is owner of question
    return _doc(item.path).set({'accepted': value}, SetOptions(merge: true));
  }

  Stream<List<Reaction>> reactions(Doc item) {
    return _reactions(item.path)
        .snapshots()
        .map((event) => event.docs.mapToList((e) => Reaction.fromSnapshot(e)));
  }

  static Stream<int> reactionCount(Doc item) {
    return _reactions(item.path).snapshots().map((event) => event.size);
  }

  static Stream<Availability> isReactionAvailable(Reactionable target) {
    return _auth.authStateChanges().flatMapUntilNext((value) =>
        _doc(target.personPath).id == value?.uid
            ? Stream.value(Availability.owner)
            : _reactions(target.path).doc(value?.uid).snapshots().map((event) =>
                event.exists
                    ? Availability.reacted
                    : Availability.not_reacted));
  }

  Future<void> createReaction(Reactionable target) {
    // todo should use isReactionAvailable before execution
    var id = _auth.currentUser?.uid;
    return _reactions(target.path)
        .doc(id)
        .set(Reaction.create(_users.doc(id).path).toJson());
  }

  Future<void> removeReaction(Reactionable target) {
    // todo should use !isReactionAvailable before execution
    var id = _auth.currentUser?.uid;
    return _reactions(target.path).doc(id).delete();
  }
}

class AuthCanceled implements Exception {
  @override
  String toString() => 'AuthCanceled: cancelled by user';
}
