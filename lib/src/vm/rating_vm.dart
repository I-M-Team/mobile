import 'package:app/async.dart';
import 'package:app/src/models/models.dart';
import 'package:app/src/models/person_models.dart';
import 'package:app/src/resources/local_provider.dart';
import 'package:app/src/resources/repository.dart';
import 'package:app/src/vm/vm.dart';

class RatingViewModel extends ViewModel {
  final Repository _repository;

  final Observable<List<Person>> persons;

  RatingViewModel(this._repository)
      : persons = _repository.currentRating().toObservable([]);
}
