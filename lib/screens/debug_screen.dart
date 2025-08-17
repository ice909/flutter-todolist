import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final StorageService _storageService = SharedPreferencesStorage();
  List<Task> _tasks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    try {
      final tasks = await _storageService.getTasks();

      if (!mounted) return;

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载失败: $e')));
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug - 待办事项'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('没有存储的待办事项'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题行
                          Row(
                            children: [
                              Icon(
                                task.completed
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: task.completed
                                    ? Colors.green
                                    : Colors.grey,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: task.completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),

                          // 详细信息
                          _buildDetailRow('ID', task.id),
                          if (task.content.isNotEmpty)
                            _buildDetailRow('内容', task.content),
                          if (task.parentId.isNotEmpty)
                            _buildDetailRow('父任务ID', task.parentId),
                          _buildDetailRow('状态', task.completed ? '已完成' : '待完成'),
                          _buildDetailRow('优先级', task.priority.toString()),
                          if (task.tags != null && task.tags!.isNotEmpty)
                            _buildDetailRow('标签', task.tags!),
                          _buildDetailRow('排序值', task.sortOrder.toString()),
                          _buildDetailRow('展开状态', task.expanded ? '是' : '否'),
                          _buildDetailRow(
                            '创建时间',
                            _formatDateTime(task.createdAt),
                          ),
                          if (task.updatedAt != null)
                            _buildDetailRow(
                              '更新时间',
                              _formatDateTime(task.updatedAt!),
                            ),
                          if (task.deletedAt != null)
                            _buildDetailRow(
                              '删除时间',
                              _formatDateTime(task.deletedAt!),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      // 底部显示统计信息
      bottomNavigationBar: _tasks.isNotEmpty
          ? Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('总数', _tasks.length.toString(), Colors.blue),
                  _buildStatItem(
                    '已完成',
                    _tasks.where((t) => t.completed).length.toString(),
                    Colors.green,
                  ),
                  _buildStatItem(
                    '待完成',
                    _tasks.where((t) => !t.completed).length.toString(),
                    Colors.orange,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
