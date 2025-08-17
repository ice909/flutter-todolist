import 'package:flutter/material.dart';
import './debug_screen.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../widgets/task_widget.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key, required this.title});

  final String title;

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final StorageService _storageService = SharedPreferencesStorage();
  List<Task> _todos = [];
  final TextEditingController _titleController = TextEditingController();
  Key? key;
  bool _isLoading = false;
  // 分离已完成和未完成的任务
  List<Task> get _activeTodos =>
      _todos.where((todo) => !todo.completed).toList();
  List<Task> get _completedTodos =>
      _todos.where((todo) => todo.completed).toList();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    setState(() => _isLoading = true);
    try {
      final todos = await _storageService.getTasks();
      setState(() {
        _todos = todos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _saveTodo(BuildContext context) async {
    final title = _titleController.text.trim();
    if (title.isNotEmpty) {
      Navigator.of(context).pop();
      final newTask = await _storageService.addTask(title);
      setState(() {
        // 将新任务添加到列表顶部
        _todos.insert(0, newTask);
      });
    }
  }

  // toggle completed status
  void _toggleTodoCompleted(Task task) async {
    final updatedTask = task.copyWith(completed: !task.completed);
    await _storageService.updateTask(updatedTask);
    setState(() {
      final index = _todos.indexOf(task);
      if (index != -1) {
        _todos[index] = updatedTask;
      }
    });
  }

  void _showAddTodoBottomSheet() {
    _titleController.clear();

    WoltModalSheet.show<void>(
      context: context,
      enableDrag: true,
      showDragHandle: false,
      useSafeArea: true,
      pageListBuilder: (modalSheetContext) {
        return [
          WoltModalSheetPage(
            resizeToAvoidBottomInset: true,
            hasSabGradient: false,
            topBarTitle: Text(
              '添加待办事项',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            isTopBarLayerAlwaysVisible: true,
            trailingNavBarWidget: IconButton(
              padding: const EdgeInsets.all(20),
              icon: const Icon(Icons.close),
              onPressed: Navigator.of(modalSheetContext).pop,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: '待办标题',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) => _saveTodo(modalSheetContext),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          minimumSize: Size(70, 44),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        onPressed: () => Navigator.of(modalSheetContext).pop(),
                        child: Text('取消'),
                      ),
                      SizedBox(width: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          minimumSize: Size(70, 44),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        onPressed: () => _saveTodo(modalSheetContext),
                        child: Text('保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DebugScreen()),
              );
            },
            tooltip: 'Debug',
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.only(top: 8),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _todos.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.task_alt, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '暂无待办事项',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '点击右下角按钮添加新任务',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadTodos,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 未完成的任务列表
                      if (_activeTodos.isNotEmpty) ...[
                        ListView.builder(
                          padding: EdgeInsets.only(bottom: 8),
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _activeTodos.length,
                          itemBuilder: (context, index) {
                            return TaskWidget(
                              todo: _activeTodos[index],
                              onToggle: () =>
                                  _toggleTodoCompleted(_activeTodos[index]),
                              onDelete: () => (),
                            );
                          },
                        ),
                      ],

                      // 已完成任务区域
                      if (_completedTodos.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            top: 0,
                            bottom: 4,
                          ),
                          child: Text(
                            '已完成',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _completedTodos.length,
                          itemBuilder: (context, index) {
                            return TaskWidget(
                              todo: _completedTodos[index],
                              onToggle: () =>
                                  _toggleTodoCompleted(_completedTodos[index]),
                              onDelete: () => (),
                            );
                          },
                        ),
                      ],

                      // 底部留白，避免被 FAB 遮挡
                      SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoBottomSheet,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
