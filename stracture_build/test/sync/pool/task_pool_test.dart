import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  test('task can be executed up to the pool limit', () {
    var taskPool = TaskPool(3);
    for (var i = 0; i < 3; i++) {
      expect(taskPool.execute((task) => null), completes);
    }
  });
  test('the pool limit test if pool size is zero', () {
    expect(() => TaskPool(0), throwsA(TypeMatcher<ArgumentError>()));
  });
  test('task can be executed with TaskHandler test Completed Task Count', () async {
    var taskPool = TaskPool(3);
    int completedTskCount = 0;
    taskPool.onTaskRequestHandler((task) {
      if (task.isDone) {
        completedTskCount++;
      }
    });

    for (var i = 0; i < 3; i++) {
      expect(taskPool.execute((task) => null), completes);
    }

    await Future.delayed(const Duration(seconds: 1), () {});

    expect(completedTskCount, 3);
  });
  test("time out if there are no pending requests", () {
    FakeAsync().run((async) {
      var taskPool = TaskPool(3, timeout: const Duration(seconds: 3));
      for (var i = 0; i < 10; i++) {
        expect(taskPool.execute((task) => null), completes);
      }
      async.elapse(const Duration(seconds: 4));
    });
  });
  test("Timeout test compare with pending task size", () async {
    var taskPool = TaskPool(3, timeout: const Duration(seconds: 1));
    for (var i = 0; i < 10; i++) {
      if (i < 3) {
        try {
          taskPool.execute((task) async => await Future.delayed(Duration(seconds: 1)));
        } catch (e) {}
      } else {
        expect(taskPool.execute((task) => null), throwsA(TypeMatcher<TimeoutException>()));
      }
    }
    expect(taskPool.pendingTaskSize > 0, true);
    await Future.delayed(Duration(seconds: 1));
    expect(taskPool.pendingTaskSize, 0);
  });
  test("test timeout compare with pending task size", () {
    FakeAsync().run((async) {
      var taskPool = TaskPool(3, timeout: const Duration(seconds: 3));
      for (var i = 0; i < 10; i++) {
        expect(taskPool.execute((task) async {
          await Future.delayed(const Duration(seconds: 1), () {});
        }), completes);
      }
      expect(taskPool.pendingTaskSize > 0, true);

      async.elapse(const Duration(seconds: 4));
    });
  });
  test("Test TaskPool Close", () {
    var taskPool = TaskPool(3)..close();
    expect(taskPool.isClosed, true);
    expect(taskPool.done, completes);
    expect(taskPool.execute((task) => null), throwsA(TypeMatcher<StateError>()));
  });

  test("Test Task released once", () async {
    var taskPool = TaskPool(3);
    Task? task = await taskPool.run(taskPriority: TaskPriority.immediately, taskTag: "", taskData: "");
    task?.release();
    expect(task?.isDone, true);
    await Future.delayed(Duration.zero);
    expect(task?.release, throwsA(TypeMatcher<StateError>()));
  });

  test("Test TaskPool closed State Error Exception", () async {
    var taskPool = TaskPool(3)..close();
    expect(() => taskPool.run(taskPriority: TaskPriority.immediately, taskTag: "", taskData: "")
        , throwsA(TypeMatcher<StateError>()));
    expect(() => taskPool.execute((task) => null), throwsA(TypeMatcher<StateError>()));
  });
}
