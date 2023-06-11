import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'memos.g.dart';

/// `Memo`という名前で、メモ情報を保持するクラス。
@DataClassName('Memo')
class Memos extends Table {
  /// メモのID。自動インクリメントする整数値。
  IntColumn get id => integer().autoIncrement()();

  /// メモのタイトル。1から50文字のテキスト。
  TextColumn get title => text().withLength(min: 1, max: 50)();

  /// メモの内容。1から1000文字のテキスト。
  TextColumn get content => text().withLength(min: 1, max: 1000)();
}

/// `Memos`テーブルを含むデータベースを表現するクラス。
///
/// データベースの構造や動作をコードによってモデリングする。
@DriftDatabase(tables: [Memos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// データベースのスキーマバージョンを返す。現在は1。
  @override
  int get schemaVersion => 1;
}

/// データベースから全てのメモをストリームとして取得する。
/// メモが追加、更新、削除されると、このストリームは新しいリストを返す。
Stream<List<Memo>> watchAllMemos(AppDatabase db) {
  return db.select(db.memos).watch();
}

/// データベースから全てのメモを一度だけ取得する。
Future<List<Memo>> getAllMemos(AppDatabase db) {
  return db.select(db.memos).get();
}

/// 新しいメモをデータベースに挿入する。
Future insertMemo(AppDatabase db, Memo memo) {
  return db.into(db.memos).insert(memo);
}

/// メモを更新する。
Future updateMemo(AppDatabase db, Memo memo) {
  return db.update(db.memos).replace(memo);
}

/// データベースからメモを削除する。
Future deleteMemo(AppDatabase db, Memo memo) {
  return db.delete(db.memos).delete(memo);
}

/// アプリケーションのドキュメントディレクトリにデータベースファイルを作成し、接続する。
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'memos.sqlite'));
    return NativeDatabase(file);
  });
}
