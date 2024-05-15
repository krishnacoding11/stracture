import 'dart:async';
import 'dart:math';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:stack_trace/stack_trace.dart';

import '../../logger/logger.dart';

typedef OnTaskRequestHandler = void Function(Task task);

class TaskPool {
  final _requestedTask = PriorityQueue<Task>();
  StreamController<Task>? taskStatusStreamController = StreamController.broadcast();
  int _maxAllocatedTask;
  int _allocatedTask = 0;

  RestartableTimer? _timer;

  final Duration? _timeout;

  FutureGroup? _closeGroup;

  set maxAllocatedTask(int taskNumber) {
    _maxAllocatedTask = taskNumber;
  }

  bool get isClosed => _closeMemo.hasRun;

  Future get done => _closeMemo.future;

  int get pendingTaskSize => _requestedTask.length;

  static const TaskPriority taskPriority = TaskPriority.regular;

  num _taskNumber = pow(-2, 53);

  OnTaskRequestHandler? _onTaskRequestHandler;

  TaskPool(this._maxAllocatedTask, {Duration? timeout}) : _timeout = timeout {
    if (_maxAllocatedTask <= 0) {
      throw ArgumentError.value(_maxAllocatedTask, 'maxAllocatedTask', 'Must be greater than zero.');
    }

    if (timeout != null) {
      _timer = RestartableTimer(timeout, _onTimeout)..cancel();
    }
  }

  /// Request a [Task].
  ///
  /// If the maximum number of tasks is already allocated, this will delay
  /// until one of them is released.
  Future<Task>? run({TaskPriority taskPriority = taskPriority, String? taskTag, dynamic taskData}) {
    taskStatusStreamController ??= StreamController.broadcast();
    if (isClosed) {
      throw StateError('request() may not be called on a closed Task Pool.');
    }

    if (_allocatedTask < _maxAllocatedTask) {
      _allocatedTask++;
      _taskNumber++;
      var task = Task._(this, _taskNumber, taskPriority: taskPriority, taskTag: taskTag ?? "", taskData: taskData);
      _notifyTaskStatus(task);
      return Future.value(task);
    } else {
      _taskNumber++;
      var task = Task._(this, _taskNumber, taskPriority: taskPriority, taskTag: taskTag ?? "", taskData: taskData);
      _requestedTask.add(task);
      _resetTimer();
      _notifyTaskStatus(task);
      return task.resultCompleter.future;
    }
  }

  /// Requests a task for the duration of [callback], which may return a
  /// Future.
  ///
  /// The return value of [callback] is piped to the returned Future.
  Future<T> execute<T>(FutureOr<T> Function(Task? task) callback, {TaskPriority taskPriority = taskPriority, String? taskTag, dynamic taskData}) async {
    if (isClosed) {
      throw StateError('withResource() may not be called on a closed Pool.');
    }

    var task = await run(taskPriority: taskPriority, taskTag: taskTag, taskData: taskData);
    Log.d("TaskPool Task Start ${task?.taskTag} - ${task?.taskNumber}");
    try {
      return await callback(task);
    } finally {
      Log.d("TaskPool Task End ${task?.taskTag} - ${task!.taskNumber}");
      task.release();
    }
  }

  Future close() => _closeMemo.runOnce(() {
        if (_closeGroup != null) return _closeGroup!.future;
        _closeGroup = FutureGroup();
        clearAllTask();
        if (_allocatedTask == 0) _closeGroup!.close();
        return _closeGroup!.future;
      });

  final _closeMemo = AsyncMemoizer();

  /// If there are any pending requests, this will fire the oldest one.
  void _onTaskReleased() {
    _resetTimer();

    if (_requestedTask.isNotEmpty) {
      var task = _requestedTask.removeFirst();
      task.resultCompleter.complete(task);
    } else {
      _allocatedTask--;
      if (isClosed && _allocatedTask == 0) _closeGroup!.close();
    }
  }

  /// A resource has been requested, allocated, or released.
  void _resetTimer() {
    if (_timer == null) return;

    if (_requestedTask.isEmpty) {
      _timer!.cancel();
    } else {
      _timer!.reset();
    }
  }

  /// Handles [_timer] timing out by causing all pending resource task completer to
  /// emit exceptions.
  void _onTimeout() {
    for (var task in _requestedTask.toList()) {
      task.resultCompleter.completeError(
          TimeoutException(
              'Pool deadlock: all Task have been '
              'allocated for too long.',
              _timeout),
          Chain.current());
    }
    _requestedTask.clear();
    _timer = null;
  }

  void clearAllTask() {
    taskStatusStreamController?.close();
    taskStatusStreamController = null;
    _resetTimer();
    _allocatedTask = 0;
    _requestedTask.clear();
  }

  /// Notify task status listener.
  void onTaskRequestHandler(OnTaskRequestHandler onTaskRequestHandler) {
    _onTaskRequestHandler = onTaskRequestHandler;
  }

  void _notifyTaskStatus(Task task) {
    if (_onTaskRequestHandler != null) {
      // _onTaskRequestHandler!(task);
    }
    taskStatusStreamController?.sink.add(task);
  }

}

enum TaskPriority { immediately, high, regular, low, last }

class Task implements Comparable<Task> {
  final TaskPool _taskPool;

  final resultCompleter = Completer<Task>();

  TaskPriority taskPriority;

  bool _released = false;

  bool get isDone => _released;

  num taskNumber;

  String taskTag;

  dynamic taskData;

  Task._(this._taskPool, this.taskNumber, {this.taskPriority = TaskPool.taskPriority, required this.taskTag, this.taskData});

  void release() {
    if (_released) {
      throw StateError('A TaskPool may only be released once.');
    }
    _released = true;
    _taskPool._notifyTaskStatus(this);
    _taskPool._onTaskReleased();
  }

  @override
  int compareTo(Task other) {
    final index = TaskPriority.values.indexOf;
    return index(taskPriority) > index(other.taskPriority) ? 1 : -1;
  }
}
