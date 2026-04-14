import 'dart:async';

/// After the first successful [List] event, transient stream errors (e.g.
/// Supabase realtime/WebSocket) re-emit the last snapshot instead of an error,
/// so [StreamProvider] stays on [AsyncData] when possible.
Stream<List<T>> replayLastListOnStreamError<T>(Stream<List<T>> source) {
  final controller = StreamController<List<T>>();
  List<T>? lastGood;

  final subscription = source.listen(
    (event) {
      lastGood = event;
      if (!controller.isClosed) controller.add(event);
    },
    onError: (Object error, StackTrace stackTrace) {
      if (lastGood != null) {
        if (!controller.isClosed) {
          controller.add(List<T>.from(lastGood!));
        }
      } else if (!controller.isClosed) {
        controller.addError(error, stackTrace);
      }
    },
    onDone: () {
      if (!controller.isClosed) controller.close();
    },
    cancelOnError: false,
  );

  controller.onCancel = () => subscription.cancel();
  return controller.stream;
}
