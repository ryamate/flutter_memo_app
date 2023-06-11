import 'package:flutter/material.dart';

import 'database/memos.dart';

void main() {
  final database = AppDatabase();
  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  /// MyApp のコンストラクタ。
  ///
  /// [database] はメモの保存や取得に使われるデータベースオブジェクト。
  const MyApp({
    Key? key,
    required this.database,
  }) : super(key: key);

  final AppDatabase database;

  /// MyApp のビルドメソッド。MaterialApp ウィジェットを返す。
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drift Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Drift Memo App',
        database: database,
      ),
    );
  }
}

/// アプリケーションのホームページとなるウィジェット。
class MyHomePage extends StatefulWidget {
  /// MyHomePage のコンストラクタ。
  ///
  /// [title] はアプリケーションのタイトル。
  /// [database] はメモの保存や取得に使われるデータベースオブジェクト。
  const MyHomePage({
    Key? key,
    required this.title,
    required this.database,
  }) : super(key: key);

  final String title;
  final AppDatabase database;

  /// MyHomePage の State を生成する。
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// MyHomePage の状態を管理するクラス。
class _MyHomePageState extends State<MyHomePage> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  int? _editingMemoId;

  /// State の初期化時に実行される。
  ///
  /// メモのタイトルと内容を編集するための TextEditingController を初期化する。
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
  }

  /// Stateの破棄時に実行される。
  ///
  /// メモのタイトルと内容を編集するための TextEditingController を破棄する。
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 新しいメモを挿入または既存のメモを更新する。
  Future<void> _insertOrUpdateMemo() async {
    final title = _titleController.text;
    final content = _contentController.text;
    if (_editingMemoId != null) {
      final memo = Memo(
        id: _editingMemoId!,
        title: title,
        content: content,
      );
      await updateMemo(widget.database, memo);
    } else {
      final id = DateTime.now().millisecondsSinceEpoch;
      final memo = Memo(
        id: id,
        title: title,
        content: content,
      );
      await insertMemo(widget.database, memo);
    }
    _titleController.clear();
    _contentController.clear();
    _editingMemoId = null;
  }

  /// メモを削除する。
  Future<void> _deleteMemo(Memo memo) async {
    await deleteMemo(widget.database, memo);
  }

  /// メモの編集を開始する。
  void _startEditingMemo(Memo memo) {
    _editingMemoId = memo.id;
    _titleController.text = memo.title;
    _contentController.text = memo.content;
  }

  /// MyHomePage のビルドメソッド。 UI を構築する。
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<List<Memo>>(
        stream: watchAllMemos(widget.database),
        builder: (context, snapshot) {
          final memos = snapshot.data ?? [];
          return ListView.builder(
            itemCount: memos.length,
            itemBuilder: (context, index) {
              final memo = memos[index];
              return ListTile(
                title: Text(memo.title),
                subtitle: Text(memo.content),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _startEditingMemo(memo),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteMemo(memo),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _insertOrUpdateMemo,
        tooltip: 'Insert Memo',
        child: const Icon(Icons.add),
      ),
      bottomSheet: SizedBox(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: 16,
            top: 32,
            right: 16,
            bottom: 16,
          ),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
