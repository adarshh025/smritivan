// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get nativeLanguage => text().withDefault(const Constant('en'))();
  TextColumn get region => text().nullable()();
  TextColumn get userType => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class GameSessions extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get gameType => text()();
  IntColumn get durationSeconds => integer()();
  RealColumn get difficultyLevel => real()();
  IntColumn get reactionTimeMs => integer()();
  RealColumn get successRate => real()();
  RealColumn get cvs => real()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Reminders extends Table {
  TextColumn get id => text()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get type => text()();
  DateTimeColumn get time => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class CaregiverAlerts extends Table {
  TextColumn get alertId => text()();
  TextColumn get triggerReason => text()();
  TextColumn get urgency => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {alertId};
}

@DriftDatabase(tables: [Users, GameSessions, Reminders, CaregiverAlerts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'smritivan.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

