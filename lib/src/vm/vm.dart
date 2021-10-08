import 'package:app/async.dart';
import 'package:app/extensions.dart';
import 'package:flutter/widgets.dart' hide Action;
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

export 'package:flutter_mobx/flutter_mobx.dart' hide version;
export 'package:mobx/mobx.dart' hide Listenable;
export 'package:provider/provider.dart' hide Dispose;

export 'main_vm.dart';
export 'stream_view_model.dart';

abstract class ViewModel {
  var _activeCount = 0;

  void _onSubscribe() {
    activeStateChanged(true);
  }

  void _onDispose() {
    activeStateChanged(false);
  }

  void activeStateChanged(bool active) {
    var wasInactive = _activeCount == 0;
    _activeCount += active ? 1 : -1;
    if (wasInactive && active) {
      onActive();
    }
    if (_activeCount == 0 && !active) {
      onInactive();
    }
  }

  void onActive() {}

  void onInactive() {}
}

mixin ViewModelMixin<T extends ViewModel, W extends StatefulWidget>
    on State<W> {
  late T _vm;

  T get vm => _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<T>();
    _vm._onSubscribe();
  }

  @override
  void dispose() {
    _vm._onDispose();
    super.dispose();
  }
}

abstract class ViewModelState<T extends ViewModel, W extends StatefulWidget>
    extends State<W> {
  late T _vm;

  T get vm => _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<T>();
    _vm._onSubscribe();
  }

  @override
  void dispose() {
    _vm._onDispose();
    super.dispose();
  }
}

extension ObservableExtension<T> on T {
  Observable<T> toObservable({ReactiveContext? context, String? name}) =>
      Observable<T>(this, context: context, name: name);
}

extension StreamConversionExtension<T> on Stream<T> {
  Observable<T> toObservable(T initialValue,
      {String? name, ReactiveContext? context, EqualityComparer<T>? equals}) {
    StreamSubscription? disposable;
    var observable = Observable<T>(initialValue,
        context: context, name: name, equals: equals);
    var _listenCount = 0;
    return observable
      ..onBecomeObserved(() {
        printLog(() => '${name ?? this.hashCode}.onBecomeObserved');
        _listenCount++;
        if (disposable == null) {
          printLog(() => '${name ?? this.hashCode}.onStartSubscription');
          disposable = this
              .doOnError((e, s) => printLog(() => s))
              .listen((event) => observable.set(event));
        } else if (disposable!.isPaused) {
          printLog(() => '${name ?? this.hashCode}.onStartSubscription');
          disposable?.resume();
        }
      })
      ..onBecomeUnobserved(() {
        printLog(() => '${name ?? this.hashCode}.onBecomeUnobserved');
        _listenCount--;
        if (_listenCount == 0 && !disposable!.isPaused) {
          printLog(() => '${name ?? this.hashCode}.onPauseSubscription');
          disposable?.pause();
          // todo resolve when to cancel()
        }
      });
  }
}

extension ObservableConversionExtension<T> on Observable<T> {
  Stream<T> toStream({bool fireImmediately = true}) {
    return StreamController<T>.broadcast().also((it) {
      void Function()? dispose;
      it.onListen = () => dispose = this.observe(
            (n) => it.add(n.newValue as T),
            fireImmediately: fireImmediately,
          );
      it.onCancel = () => dispose?.call();
    }).stream;
  }

  void set(T value) => runInAction(() => this.value = value);

  T get() => this.value;
}

extension ComputedConversionExtension<T> on Computed<T> {
  Stream<T> toStream() {
    return StreamController<T>.broadcast().also((it) {
      late void Function() dispose;
      it.onListen = () => dispose = this.observe(
            (n) => it.add(n.newValue as T),
          );
      it.onCancel = () => dispose.call();
    }).stream;
  }
}

extension DisposerExtension on List<ReactionDisposer> {
  void disposeAll() => this.forEach((d) => d());
}
