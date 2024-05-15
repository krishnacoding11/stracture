/// actionsCount : {"OverDueTasks":523,"NewTasksAssignedToday":0,"TasksDueToday":0,"TasksDueThisWeek":0}

class TaskActionCountVo {
  TaskActionCountVo({
      ActionsCount? actionsCount,}){
    _actionsCount = actionsCount;
}

  TaskActionCountVo.fromJson(dynamic json) {
    _actionsCount = json['actionsCount'] != null ? ActionsCount.fromJson(json['actionsCount']) : null;
  }
  ActionsCount? _actionsCount;
TaskActionCountVo copyWith({  ActionsCount? actionsCount,
}) => TaskActionCountVo(  actionsCount: actionsCount ?? _actionsCount,
);
  ActionsCount? get actionsCount => _actionsCount;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_actionsCount != null) {
      map['actionsCount'] = _actionsCount?.toJson();
    }
    return map;
  }

}

/// OverDueTasks : 523
/// NewTasksAssignedToday : 0
/// TasksDueToday : 0
/// TasksDueThisWeek : 0

class ActionsCount {
  ActionsCount({
      int? overDueTasks, 
      int? newTasksAssignedToday, 
      int? tasksDueToday, 
      int? tasksDueThisWeek,}){
    _overDueTasks = overDueTasks;
    _newTasksAssignedToday = newTasksAssignedToday;
    _tasksDueToday = tasksDueToday;
    _tasksDueThisWeek = tasksDueThisWeek;
}

  ActionsCount.fromJson(dynamic json) {
    _overDueTasks = json['OverDueTasks'];
    _newTasksAssignedToday = json['NewTasksAssignedToday'];
    _tasksDueToday = json['TasksDueToday'];
    _tasksDueThisWeek = json['TasksDueThisWeek'];
  }
  int? _overDueTasks;
  int? _newTasksAssignedToday;
  int? _tasksDueToday;
  int? _tasksDueThisWeek;
ActionsCount copyWith({  int? overDueTasks,
  int? newTasksAssignedToday,
  int? tasksDueToday,
  int? tasksDueThisWeek,
}) => ActionsCount(  overDueTasks: overDueTasks ?? _overDueTasks,
  newTasksAssignedToday: newTasksAssignedToday ?? _newTasksAssignedToday,
  tasksDueToday: tasksDueToday ?? _tasksDueToday,
  tasksDueThisWeek: tasksDueThisWeek ?? _tasksDueThisWeek,
);
  int? get overDueTasks => _overDueTasks;
  int? get newTasksAssignedToday => _newTasksAssignedToday;
  int? get tasksDueToday => _tasksDueToday;
  int? get tasksDueThisWeek => _tasksDueThisWeek;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['OverDueTasks'] = _overDueTasks;
    map['NewTasksAssignedToday'] = _newTasksAssignedToday;
    map['TasksDueToday'] = _tasksDueToday;
    map['TasksDueThisWeek'] = _tasksDueThisWeek;
    return map;
  }

}