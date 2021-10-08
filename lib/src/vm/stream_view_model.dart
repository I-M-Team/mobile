import 'package:app/async.dart';
import 'package:app/extensions.dart';
import 'package:app/widgets.dart';
import 'package:app/src/vm/vm.dart';
import 'package:flutter/widgets.dart';

class StreamViewModel extends ViewModel {
  final loading = Observable<bool>(false);
  final error = Observable<Object?>(null);
  var _loadingCount = 0;
  final _disp = <StreamSubscription>[];

  @override
  void onInactive() {
    _disp.cancelAll();
    super.onInactive();
  }

  Stream<T> handleLoad<T>(Stream<T> stream) {
    return _handleLoading(stream).doOnError((e, s) => setError(e));
  }

  StreamSubscription<T> listen<T>(Stream<T> stream, {void onData(T event)?}) {
    return handleLoad(stream).listen(onData).also(_disp.add);
  }

  FutureSubscription<T> load<T>(Stream<T> stream) {
    return handleLoad(stream).firstElementFuture().also(_disp.add);
  }

  StreamSubscription<T> toDispose<T>(StreamSubscription<T> subscription) =>
      subscription.also(_disp.add);

  FutureSubscription<T> toDisposeFuture<T>(
          FutureSubscription<T> subscription) =>
      subscription.also(_disp.add);

  Future<T> loadFuture<T>(Future<T> future) {
    _markLoading(true);
    return future.doOnError((e, s) {
      _markLoading(false);
      setError(e);
    }).doOnData((value) {
      _markLoading(false);
    });
  }

  Stream<T> _handleLoading<T>(Stream<T> stream) {
    var loading = false;
    return stream.doOnListen(() {
      if (!loading) {
        _markLoading(true);
        loading = true;
      }
    }).doOnResume(() {
      if (!loading) {
        _markLoading(true);
        loading = true;
      }
    }).doOnData((v) {
      if (loading) {
        _markLoading(false);
        loading = false;
      }
    }).doOnDone(() {
      if (loading) {
        _markLoading(false);
        loading = false;
      }
    }).doOnError((e, s) {
      if (loading) {
        _markLoading(false);
        loading = false;
      }
    });
  }

  void _markLoading(bool add) {
    _loadingCount += add ? 1 : -1;
    var l = _loadingCount > 0;
    if (loading.value != l) {
      loading.set(l);
    }
  }

  StreamViewModelLoader newLoader() => StreamViewModelLoader._(
        () => _markLoading(true),
        () => _markLoading(false),
      );

  void setError(Object? e) => error.set(e);

  void clearError() => error.value != null ? setError(null) : null;
}

class StreamViewModelLoader {
  var _loading = false;
  void Function() _onLoading;
  void Function() _onComplete;

  StreamViewModelLoader._(this._onLoading, this._onComplete);

  void loading() {
    if (!_loading) {
      _onLoading();
      _loading = true;
    }
  }

  void complete() {
    if (_loading) {
      _onComplete();
      _loading = false;
    }
  }
}

extension StreamViewModelExtension<T> on Stream<T> {
  Stream<T> doOnLoad(StreamViewModelLoader loader) {
    return this
        .doOnListen(() => loader.loading())
        .doOnData((it) => loader.complete())
        .doOnError((it, s) => loader.complete());
  }
}

abstract class StreamState<VM extends StreamViewModel, W extends StatefulWidget>
    extends ViewModelState<VM, W> {
  late List<ReactionDisposer> _disposers;

  @override
  void initState() {
    super.initState();
    _disposers = [
      reaction(
            (_) => vm.error.value,
            (Object? event) => handleError(event),
        delay: 1000,
      ),
    ];
  }

  void handleError(event) {
    if (event != null) {
      context.scaffoldMessenger
          .showSnackBarError(error: event, onClosed: () => vm.clearError());
    } else {
      context.scaffoldMessenger.hideCurrentSnackBar();
    }
  }

  @override
  void dispose() {
    _disposers.disposeAll();
    super.dispose();
  }
}