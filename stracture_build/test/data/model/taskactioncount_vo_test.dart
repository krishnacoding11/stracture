import 'dart:convert';
import 'package:field/data/model/taskactioncount_vo.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson should convert JSON map to TaskActionCountVo object', () {
    final jsonString = '{"actionsCount": {"OverDueTasks": 3, "NewTasksAssignedToday": 5, "TasksDueToday": 10, "TasksDueThisWeek": 15}}';
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final taskActionCountVo = TaskActionCountVo.fromJson(jsonMap);

    expect(taskActionCountVo.actionsCount, isNotNull);
    expect(taskActionCountVo.actionsCount!.overDueTasks, equals(3));
    expect(taskActionCountVo.actionsCount!.newTasksAssignedToday, equals(5));
    expect(taskActionCountVo.actionsCount!.tasksDueToday, equals(10));
    expect(taskActionCountVo.actionsCount!.tasksDueThisWeek, equals(15));
  });

  test('toJson should convert TaskActionCountVo object to JSON map', () {
    final actionsCount = ActionsCount(
      overDueTasks: 3,
      newTasksAssignedToday: 5,
      tasksDueToday: 10,
      tasksDueThisWeek: 15,
    );

    final taskActionCountVo = TaskActionCountVo(actionsCount: actionsCount);

    final jsonMap = taskActionCountVo.toJson();

    expect(jsonMap['actionsCount'], isNotNull);
    expect(jsonMap['actionsCount']['OverDueTasks'], equals(3));
    expect(jsonMap['actionsCount']['NewTasksAssignedToday'], equals(5));
    expect(jsonMap['actionsCount']['TasksDueToday'], equals(10));
    expect(jsonMap['actionsCount']['TasksDueThisWeek'], equals(15));
  });

  test('TaskActionCountVo copyWith method should return a new instance with updated values', () {
    // Create an instance of ActionsCount with initial values
    ActionsCount initialActionsCount = ActionsCount();

    // Create an instance of TaskActionCountVo with initial values
    TaskActionCountVo initialTaskActionCountVo = TaskActionCountVo(
      actionsCount: initialActionsCount,
    );

    // Use copyWith to create a new instance with updated values
    ActionsCount updatedActionsCount = ActionsCount();
    TaskActionCountVo updatedTaskActionCountVo = initialTaskActionCountVo.copyWith(
      actionsCount: updatedActionsCount,
    );

    // Verify that the new instance has the updated values
    expect(updatedTaskActionCountVo.actionsCount, updatedActionsCount);

    // Verify that the initial instance remains unchanged
    expect(initialTaskActionCountVo.actionsCount, initialActionsCount);
  });


  test('ActionsCount copyWith method should return a new instance with updated values', () {
    // Create an instance of ActionsCount with initial values
    ActionsCount initialActionsCount = ActionsCount(
      overDueTasks: 10,
      newTasksAssignedToday: 5,
      tasksDueToday: 7,
      tasksDueThisWeek: 15,
    );

    // Use copyWith to create a new instance with updated values
    ActionsCount updatedActionsCount = initialActionsCount.copyWith(
      overDueTasks: 15,
      newTasksAssignedToday: 8,
      tasksDueToday: 12,
      tasksDueThisWeek: 25,
    );

    // Verify that the new instance has the updated values
    expect(updatedActionsCount.overDueTasks, 15);
    expect(updatedActionsCount.newTasksAssignedToday, 8);
    expect(updatedActionsCount.tasksDueToday, 12);
    expect(updatedActionsCount.tasksDueThisWeek, 25);

    // Verify that the initial instance remains unchanged
    expect(initialActionsCount.overDueTasks, 10);
    expect(initialActionsCount.newTasksAssignedToday, 5);
    expect(initialActionsCount.tasksDueToday, 7);
    expect(initialActionsCount.tasksDueThisWeek, 15);
  });

  test('ActionsCount copyWith method should return a new instance with updated values', () {
    // Create an instance of ActionsCount with initial values
    ActionsCount initialActionsCount = ActionsCount(
      overDueTasks: 10,
      newTasksAssignedToday: 5,
      tasksDueToday: 7,
      tasksDueThisWeek: 15,
    );

    // Use copyWith to create a new instance with updated values
    ActionsCount updatedActionsCount = initialActionsCount.copyWith(
      overDueTasks: 15,
      newTasksAssignedToday: 8,
      tasksDueToday: 12,
      tasksDueThisWeek: 25,
    );

    // Verify that the new instance has the updated values
    expect(updatedActionsCount.overDueTasks, 15);
    expect(updatedActionsCount.newTasksAssignedToday, 8);
    expect(updatedActionsCount.tasksDueToday, 12);
    expect(updatedActionsCount.tasksDueThisWeek, 25);

    // Verify that the initial instance remains unchanged
    expect(initialActionsCount.overDueTasks, 10);
    expect(initialActionsCount.newTasksAssignedToday, 5);
    expect(initialActionsCount.tasksDueToday, 7);
    expect(initialActionsCount.tasksDueThisWeek, 15);

    updatedActionsCount = initialActionsCount.copyWith(
      overDueTasks: null,
      newTasksAssignedToday: null,
      tasksDueToday: null,
      tasksDueThisWeek: null,
    );

    expect(initialActionsCount.overDueTasks, 10);
    expect(initialActionsCount.newTasksAssignedToday, 5);
    expect(initialActionsCount.tasksDueToday, 7);
    expect(initialActionsCount.tasksDueThisWeek, 15);
  });
}
