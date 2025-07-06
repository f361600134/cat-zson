import 'dart:async';
import 'package:get/get.dart';

/// 异步任务状态枚举
enum TaskStatus {
  idle,      // 空闲
  running,   // 运行中
  completed, // 已完成
  failed,    // 失败
  cancelled, // 已取消
}

/// 异步任务配置
class TaskConfig {
  final String taskId;
  final Duration interval;
  final int? maxRetries;
  final Duration? timeout;
  final bool autoStart;

  const TaskConfig({
    required this.taskId,
    this.interval = const Duration(seconds: 3),
    this.maxRetries,
    this.timeout,
    this.autoStart = true,
  });
}

/// 异步任务
class AsyncTask {
  final TaskConfig config;
  final Future<String> Function(String taskId) getStatus;
  final void Function(String taskId, String status)? onUpdate;
  final void Function(String taskId, String error)? onError;
  final bool Function(String status) isCompleted;

  Timer? _timer;
  TaskStatus _status = TaskStatus.idle;
  String _lastResult = '';
  int _retryCount = 0;

  AsyncTask({
    required this.config,
    required this.getStatus,
    required this.isCompleted,
    this.onUpdate,
    this.onError,
  });

  /// 当前状态
  TaskStatus get status => _status;

  /// 最后的结果
  String get lastResult => _lastResult;

  /// 重试次数
  int get retryCount => _retryCount;

  /// 开始任务
  void start() {
    if (_status == TaskStatus.running) return;

    _status = TaskStatus.running;
    _scheduleNext();
  }

  /// 停止任务
  void stop() {
    _timer?.cancel();
    _timer = null;
    if (_status == TaskStatus.running) {
      _status = TaskStatus.cancelled;
    }
  }

  /// 重置任务
  void reset() {
    stop();
    _status = TaskStatus.idle;
    _lastResult = '';
    _retryCount = 0;
  }

  void _scheduleNext() {
    _timer = Timer(config.interval, () async {
      await _executeTask();
    });
  }

  Future<void> _executeTask() async {
    try {
      Future<String> statusFuture = getStatus(config.taskId);
      
      // 如果设置了超时时间
      if (config.timeout != null) {
        statusFuture = statusFuture.timeout(config.timeout!);
      }

      final result = await statusFuture;
      _lastResult = result;
      _retryCount = 0; // 成功后重置重试计数

      onUpdate?.call(config.taskId, result);

      if (isCompleted(result)) {
        _status = TaskStatus.completed;
        _timer?.cancel();
      } else if (_status == TaskStatus.running) {
        _scheduleNext(); // 继续下一次轮询
      }
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _handleError(String error) {
    _retryCount++;
    
    onError?.call(config.taskId, error);

    // 检查是否超过最大重试次数
    if (config.maxRetries != null && _retryCount >= config.maxRetries!) {
      _status = TaskStatus.failed;
      _timer?.cancel();
      return;
    }

    // 如果还在运行状态，继续重试
    if (_status == TaskStatus.running) {
      _scheduleNext();
    }
  }
}

/// 轮询服务 - 管理多个异步任务
class PollingService extends GetxService {
  final Map<String, AsyncTask> _tasks = {};
  final RxMap<String, String> taskResults = <String, String>{}.obs;
  final RxMap<String, TaskStatus> taskStatuses = <String, TaskStatus>{}.obs;

  /// 添加任务
  void addTask({
    required TaskConfig config,
    required Future<String> Function(String taskId) getStatus,
    required bool Function(String status) isCompleted,
    void Function(String taskId, String status)? onUpdate,
    void Function(String taskId, String error)? onError,
  }) {
    // 防止重复添加
    if (_tasks.containsKey(config.taskId)) {
      print('[PollingService] Task ${config.taskId} already exists');
      return;
    }

    final task = AsyncTask(
      config: config,
      getStatus: getStatus,
      isCompleted: isCompleted,
      onUpdate: (taskId, status) {
        taskResults[taskId] = status;
        taskStatuses[taskId] = TaskStatus.running;
        onUpdate?.call(taskId, status);
      },
      onError: (taskId, error) {
        print('[PollingService] Task $taskId error: $error');
        onError?.call(taskId, error);
      },
    );

    _tasks[config.taskId] = task;
    taskStatuses[config.taskId] = TaskStatus.idle;

    if (config.autoStart) {
      task.start();
    }

    print('[PollingService] Added task: ${config.taskId}');
  }

  /// 开始指定任务
  void startTask(String taskId) {
    final task = _tasks[taskId];
    if (task != null) {
      task.start();
      taskStatuses[taskId] = TaskStatus.running;
      print('[PollingService] Started task: $taskId');
    }
  }

  /// 停止指定任务
  void stopTask(String taskId) {
    final task = _tasks[taskId];
    if (task != null) {
      task.stop();
      taskStatuses[taskId] = task.status;
      print('[PollingService] Stopped task: $taskId');
    }
  }

  /// 重置指定任务
  void resetTask(String taskId) {
    final task = _tasks[taskId];
    if (task != null) {
      task.reset();
      taskStatuses[taskId] = TaskStatus.idle;
      taskResults.remove(taskId);
      print('[PollingService] Reset task: $taskId');
    }
  }

  /// 移除任务
  void removeTask(String taskId) {
    final task = _tasks[taskId];
    if (task != null) {
      task.stop();
      _tasks.remove(taskId);
      taskResults.remove(taskId);
      taskStatuses.remove(taskId);
      print('[PollingService] Removed task: $taskId');
    }
  }

  /// 获取任务状态
  TaskStatus? getTaskStatus(String taskId) {
    return taskStatuses[taskId];
  }

  /// 获取任务结果
  String? getTaskResult(String taskId) {
    return taskResults[taskId];
  }

  /// 获取任务详细信息
  AsyncTask? getTask(String taskId) {
    return _tasks[taskId];
  }

  /// 获取所有任务ID
  List<String> get allTaskIds => _tasks.keys.toList();

  /// 获取运行中的任务
  List<String> get runningTasks {
    return _tasks.entries
        .where((entry) => entry.value.status == TaskStatus.running)
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取已完成的任务
  List<String> get completedTasks {
    return _tasks.entries
        .where((entry) => entry.value.status == TaskStatus.completed)
        .map((entry) => entry.key)
        .toList();
  }

  /// 获取失败的任务
  List<String> get failedTasks {
    return _tasks.entries
        .where((entry) => entry.value.status == TaskStatus.failed)
        .map((entry) => entry.key)
        .toList();
  }

  /// 暂停所有任务
  void pauseAllTasks() {
    for (var task in _tasks.values) {
      if (task.status == TaskStatus.running) {
        task.stop();
      }
    }
    print('[PollingService] Paused all tasks');
  }

  /// 恢复所有任务
  void resumeAllTasks() {
    for (var entry in _tasks.entries) {
      if (entry.value.status == TaskStatus.cancelled) {
        entry.value.start();
      }
    }
    print('[PollingService] Resumed all tasks');
  }

  /// 清理所有任务
  void clearAllTasks() {
    for (var task in _tasks.values) {
      task.stop();
    }
    _tasks.clear();
    taskResults.clear();
    taskStatuses.clear();
    print('[PollingService] Cleared all tasks');
  }

  /// 获取服务统计信息
  Map<String, dynamic> getStatistics() {
    return {
      'totalTasks': _tasks.length,
      'runningTasks': runningTasks.length,
      'completedTasks': completedTasks.length,
      'failedTasks': failedTasks.length,
      'idleTasks': _tasks.values.where((t) => t.status == TaskStatus.idle).length,
      'cancelledTasks': _tasks.values.where((t) => t.status == TaskStatus.cancelled).length,
    };
  }

  @override
  void onClose() {
    clearAllTasks();
    super.onClose();
  }
}

/// 轮询任务混入 - 为GetX控制器提供轮询任务管理能力
mixin PollingMixin on GetxController {
  PollingService get pollingService => Get.find<PollingService>();

  /// 添加轮询任务的便捷方法
  void addPollingTask({
    required String taskId,
    required Future<String> Function(String) getStatus,
    required bool Function(String) isCompleted,
    Duration interval = const Duration(seconds: 3),
    int? maxRetries,
    Duration? timeout,
    bool autoStart = true,
    void Function(String taskId, String status)? onUpdate,
    void Function(String taskId, String error)? onError,
  }) {
    pollingService.addTask(
      config: TaskConfig(
        taskId: taskId,
        interval: interval,
        maxRetries: maxRetries,
        timeout: timeout,
        autoStart: autoStart,
      ),
      getStatus: getStatus,
      isCompleted: isCompleted,
      onUpdate: onUpdate,
      onError: onError,
    );
  }

  @override
  void onClose() {
    // 这里可以根据需要决定是否清理相关任务
    super.onClose();
  }
}
