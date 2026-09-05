// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nativeLanguageMeta =
      const VerificationMeta('nativeLanguage');
  @override
  late final GeneratedColumn<String> nativeLanguage = GeneratedColumn<String>(
      'native_language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
      'region', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userTypeMeta =
      const VerificationMeta('userType');
  @override
  late final GeneratedColumn<String> userType = GeneratedColumn<String>(
      'user_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, nativeLanguage, region, userType, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('native_language')) {
      context.handle(
          _nativeLanguageMeta,
          nativeLanguage.isAcceptableOrUnknown(
              data['native_language']!, _nativeLanguageMeta));
    }
    if (data.containsKey('region')) {
      context.handle(_regionMeta,
          region.isAcceptableOrUnknown(data['region']!, _regionMeta));
    }
    if (data.containsKey('user_type')) {
      context.handle(_userTypeMeta,
          userType.isAcceptableOrUnknown(data['user_type']!, _userTypeMeta));
    } else if (isInserting) {
      context.missing(_userTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nativeLanguage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}native_language'])!,
      region: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region']),
      userType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String name;
  final String nativeLanguage;
  final String? region;
  final String userType;
  final DateTime createdAt;
  const User(
      {required this.id,
      required this.name,
      required this.nativeLanguage,
      this.region,
      required this.userType,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['native_language'] = Variable<String>(nativeLanguage);
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    map['user_type'] = Variable<String>(userType);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      nativeLanguage: Value(nativeLanguage),
      region:
          region == null && nullToAbsent ? const Value.absent() : Value(region),
      userType: Value(userType),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nativeLanguage: serializer.fromJson<String>(json['nativeLanguage']),
      region: serializer.fromJson<String?>(json['region']),
      userType: serializer.fromJson<String>(json['userType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nativeLanguage': serializer.toJson<String>(nativeLanguage),
      'region': serializer.toJson<String?>(region),
      'userType': serializer.toJson<String>(userType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith(
          {int? id,
          String? name,
          String? nativeLanguage,
          Value<String?> region = const Value.absent(),
          String? userType,
          DateTime? createdAt}) =>
      User(
        id: id ?? this.id,
        name: name ?? this.name,
        nativeLanguage: nativeLanguage ?? this.nativeLanguage,
        region: region.present ? region.value : this.region,
        userType: userType ?? this.userType,
        createdAt: createdAt ?? this.createdAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nativeLanguage: data.nativeLanguage.present
          ? data.nativeLanguage.value
          : this.nativeLanguage,
      region: data.region.present ? data.region.value : this.region,
      userType: data.userType.present ? data.userType.value : this.userType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('region: $region, ')
          ..write('userType: $userType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, nativeLanguage, region, userType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.nativeLanguage == this.nativeLanguage &&
          other.region == this.region &&
          other.userType == this.userType &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nativeLanguage;
  final Value<String?> region;
  final Value<String> userType;
  final Value<DateTime> createdAt;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nativeLanguage = const Value.absent(),
    this.region = const Value.absent(),
    this.userType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nativeLanguage = const Value.absent(),
    this.region = const Value.absent(),
    required String userType,
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        userType = Value(userType);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nativeLanguage,
    Expression<String>? region,
    Expression<String>? userType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nativeLanguage != null) 'native_language': nativeLanguage,
      if (region != null) 'region': region,
      if (userType != null) 'user_type': userType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? nativeLanguage,
      Value<String?>? region,
      Value<String>? userType,
      Value<DateTime>? createdAt}) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      region: region ?? this.region,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nativeLanguage.present) {
      map['native_language'] = Variable<String>(nativeLanguage.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (userType.present) {
      map['user_type'] = Variable<String>(userType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nativeLanguage: $nativeLanguage, ')
          ..write('region: $region, ')
          ..write('userType: $userType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $GameSessionsTable extends GameSessions
    with TableInfo<$GameSessionsTable, GameSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _gameTypeMeta =
      const VerificationMeta('gameType');
  @override
  late final GeneratedColumn<String> gameType = GeneratedColumn<String>(
      'game_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _durationSecondsMeta =
      const VerificationMeta('durationSeconds');
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
      'duration_seconds', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _difficultyLevelMeta =
      const VerificationMeta('difficultyLevel');
  @override
  late final GeneratedColumn<double> difficultyLevel = GeneratedColumn<double>(
      'difficulty_level', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _reactionTimeMsMeta =
      const VerificationMeta('reactionTimeMs');
  @override
  late final GeneratedColumn<int> reactionTimeMs = GeneratedColumn<int>(
      'reaction_time_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _successRateMeta =
      const VerificationMeta('successRate');
  @override
  late final GeneratedColumn<double> successRate = GeneratedColumn<double>(
      'success_rate', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _cvsMeta = const VerificationMeta('cvs');
  @override
  late final GeneratedColumn<double> cvs = GeneratedColumn<double>(
      'cvs', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        gameType,
        durationSeconds,
        difficultyLevel,
        reactionTimeMs,
        successRate,
        cvs,
        timestamp,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<GameSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('game_type')) {
      context.handle(_gameTypeMeta,
          gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta));
    } else if (isInserting) {
      context.missing(_gameTypeMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
          _durationSecondsMeta,
          durationSeconds.isAcceptableOrUnknown(
              data['duration_seconds']!, _durationSecondsMeta));
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('difficulty_level')) {
      context.handle(
          _difficultyLevelMeta,
          difficultyLevel.isAcceptableOrUnknown(
              data['difficulty_level']!, _difficultyLevelMeta));
    } else if (isInserting) {
      context.missing(_difficultyLevelMeta);
    }
    if (data.containsKey('reaction_time_ms')) {
      context.handle(
          _reactionTimeMsMeta,
          reactionTimeMs.isAcceptableOrUnknown(
              data['reaction_time_ms']!, _reactionTimeMsMeta));
    } else if (isInserting) {
      context.missing(_reactionTimeMsMeta);
    }
    if (data.containsKey('success_rate')) {
      context.handle(
          _successRateMeta,
          successRate.isAcceptableOrUnknown(
              data['success_rate']!, _successRateMeta));
    } else if (isInserting) {
      context.missing(_successRateMeta);
    }
    if (data.containsKey('cvs')) {
      context.handle(
          _cvsMeta, cvs.isAcceptableOrUnknown(data['cvs']!, _cvsMeta));
    } else if (isInserting) {
      context.missing(_cvsMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      gameType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}game_type'])!,
      durationSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration_seconds'])!,
      difficultyLevel: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}difficulty_level'])!,
      reactionTimeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reaction_time_ms'])!,
      successRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}success_rate'])!,
      cvs: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cvs'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $GameSessionsTable createAlias(String alias) {
    return $GameSessionsTable(attachedDatabase, alias);
  }
}

class GameSession extends DataClass implements Insertable<GameSession> {
  final String id;
  final int userId;
  final String gameType;
  final int durationSeconds;
  final double difficultyLevel;
  final int reactionTimeMs;
  final double successRate;
  final double cvs;
  final DateTime timestamp;
  final String syncStatus;
  const GameSession(
      {required this.id,
      required this.userId,
      required this.gameType,
      required this.durationSeconds,
      required this.difficultyLevel,
      required this.reactionTimeMs,
      required this.successRate,
      required this.cvs,
      required this.timestamp,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<int>(userId);
    map['game_type'] = Variable<String>(gameType);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['difficulty_level'] = Variable<double>(difficultyLevel);
    map['reaction_time_ms'] = Variable<int>(reactionTimeMs);
    map['success_rate'] = Variable<double>(successRate);
    map['cvs'] = Variable<double>(cvs);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  GameSessionsCompanion toCompanion(bool nullToAbsent) {
    return GameSessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      gameType: Value(gameType),
      durationSeconds: Value(durationSeconds),
      difficultyLevel: Value(difficultyLevel),
      reactionTimeMs: Value(reactionTimeMs),
      successRate: Value(successRate),
      cvs: Value(cvs),
      timestamp: Value(timestamp),
      syncStatus: Value(syncStatus),
    );
  }

  factory GameSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSession(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      gameType: serializer.fromJson<String>(json['gameType']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      difficultyLevel: serializer.fromJson<double>(json['difficultyLevel']),
      reactionTimeMs: serializer.fromJson<int>(json['reactionTimeMs']),
      successRate: serializer.fromJson<double>(json['successRate']),
      cvs: serializer.fromJson<double>(json['cvs']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<int>(userId),
      'gameType': serializer.toJson<String>(gameType),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'difficultyLevel': serializer.toJson<double>(difficultyLevel),
      'reactionTimeMs': serializer.toJson<int>(reactionTimeMs),
      'successRate': serializer.toJson<double>(successRate),
      'cvs': serializer.toJson<double>(cvs),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  GameSession copyWith(
          {String? id,
          int? userId,
          String? gameType,
          int? durationSeconds,
          double? difficultyLevel,
          int? reactionTimeMs,
          double? successRate,
          double? cvs,
          DateTime? timestamp,
          String? syncStatus}) =>
      GameSession(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        gameType: gameType ?? this.gameType,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        difficultyLevel: difficultyLevel ?? this.difficultyLevel,
        reactionTimeMs: reactionTimeMs ?? this.reactionTimeMs,
        successRate: successRate ?? this.successRate,
        cvs: cvs ?? this.cvs,
        timestamp: timestamp ?? this.timestamp,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  GameSession copyWithCompanion(GameSessionsCompanion data) {
    return GameSession(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      difficultyLevel: data.difficultyLevel.present
          ? data.difficultyLevel.value
          : this.difficultyLevel,
      reactionTimeMs: data.reactionTimeMs.present
          ? data.reactionTimeMs.value
          : this.reactionTimeMs,
      successRate:
          data.successRate.present ? data.successRate.value : this.successRate,
      cvs: data.cvs.present ? data.cvs.value : this.cvs,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSession(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('gameType: $gameType, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('reactionTimeMs: $reactionTimeMs, ')
          ..write('successRate: $successRate, ')
          ..write('cvs: $cvs, ')
          ..write('timestamp: $timestamp, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, gameType, durationSeconds,
      difficultyLevel, reactionTimeMs, successRate, cvs, timestamp, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSession &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.gameType == this.gameType &&
          other.durationSeconds == this.durationSeconds &&
          other.difficultyLevel == this.difficultyLevel &&
          other.reactionTimeMs == this.reactionTimeMs &&
          other.successRate == this.successRate &&
          other.cvs == this.cvs &&
          other.timestamp == this.timestamp &&
          other.syncStatus == this.syncStatus);
}

class GameSessionsCompanion extends UpdateCompanion<GameSession> {
  final Value<String> id;
  final Value<int> userId;
  final Value<String> gameType;
  final Value<int> durationSeconds;
  final Value<double> difficultyLevel;
  final Value<int> reactionTimeMs;
  final Value<double> successRate;
  final Value<double> cvs;
  final Value<DateTime> timestamp;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const GameSessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.gameType = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.difficultyLevel = const Value.absent(),
    this.reactionTimeMs = const Value.absent(),
    this.successRate = const Value.absent(),
    this.cvs = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSessionsCompanion.insert({
    required String id,
    required int userId,
    required String gameType,
    required int durationSeconds,
    required double difficultyLevel,
    required int reactionTimeMs,
    required double successRate,
    required double cvs,
    this.timestamp = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        gameType = Value(gameType),
        durationSeconds = Value(durationSeconds),
        difficultyLevel = Value(difficultyLevel),
        reactionTimeMs = Value(reactionTimeMs),
        successRate = Value(successRate),
        cvs = Value(cvs);
  static Insertable<GameSession> custom({
    Expression<String>? id,
    Expression<int>? userId,
    Expression<String>? gameType,
    Expression<int>? durationSeconds,
    Expression<double>? difficultyLevel,
    Expression<int>? reactionTimeMs,
    Expression<double>? successRate,
    Expression<double>? cvs,
    Expression<DateTime>? timestamp,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (gameType != null) 'game_type': gameType,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      if (reactionTimeMs != null) 'reaction_time_ms': reactionTimeMs,
      if (successRate != null) 'success_rate': successRate,
      if (cvs != null) 'cvs': cvs,
      if (timestamp != null) 'timestamp': timestamp,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSessionsCompanion copyWith(
      {Value<String>? id,
      Value<int>? userId,
      Value<String>? gameType,
      Value<int>? durationSeconds,
      Value<double>? difficultyLevel,
      Value<int>? reactionTimeMs,
      Value<double>? successRate,
      Value<double>? cvs,
      Value<DateTime>? timestamp,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return GameSessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      gameType: gameType ?? this.gameType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      reactionTimeMs: reactionTimeMs ?? this.reactionTimeMs,
      successRate: successRate ?? this.successRate,
      cvs: cvs ?? this.cvs,
      timestamp: timestamp ?? this.timestamp,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(gameType.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (difficultyLevel.present) {
      map['difficulty_level'] = Variable<double>(difficultyLevel.value);
    }
    if (reactionTimeMs.present) {
      map['reaction_time_ms'] = Variable<int>(reactionTimeMs.value);
    }
    if (successRate.present) {
      map['success_rate'] = Variable<double>(successRate.value);
    }
    if (cvs.present) {
      map['cvs'] = Variable<double>(cvs.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('gameType: $gameType, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('difficultyLevel: $difficultyLevel, ')
          ..write('reactionTimeMs: $reactionTimeMs, ')
          ..write('successRate: $successRate, ')
          ..write('cvs: $cvs, ')
          ..write('timestamp: $timestamp, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'user_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES users (id)'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, type, time, status, syncStatus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}user_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String id;
  final int userId;
  final String type;
  final DateTime time;
  final String status;
  final String syncStatus;
  const Reminder(
      {required this.id,
      required this.userId,
      required this.type,
      required this.time,
      required this.status,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<int>(userId);
    map['type'] = Variable<String>(type);
    map['time'] = Variable<DateTime>(time);
    map['status'] = Variable<String>(status);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      time: Value(time),
      status: Value(status),
      syncStatus: Value(syncStatus),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      time: serializer.fromJson<DateTime>(json['time']),
      status: serializer.fromJson<String>(json['status']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<int>(userId),
      'type': serializer.toJson<String>(type),
      'time': serializer.toJson<DateTime>(time),
      'status': serializer.toJson<String>(status),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Reminder copyWith(
          {String? id,
          int? userId,
          String? type,
          DateTime? time,
          String? status,
          String? syncStatus}) =>
      Reminder(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        time: time ?? this.time,
        status: status ?? this.status,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      time: data.time.present ? data.time.value : this.time,
      status: data.status.present ? data.status.value : this.status,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('time: $time, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, type, time, status, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.time == this.time &&
          other.status == this.status &&
          other.syncStatus == this.syncStatus);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> id;
  final Value<int> userId;
  final Value<String> type;
  final Value<DateTime> time;
  final Value<String> status;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.time = const Value.absent(),
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String id,
    required int userId,
    required String type,
    required DateTime time,
    this.status = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        type = Value(type),
        time = Value(time);
  static Insertable<Reminder> custom({
    Expression<String>? id,
    Expression<int>? userId,
    Expression<String>? type,
    Expression<DateTime>? time,
    Expression<String>? status,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (time != null) 'time': time,
      if (status != null) 'status': status,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith(
      {Value<String>? id,
      Value<int>? userId,
      Value<String>? type,
      Value<DateTime>? time,
      Value<String>? status,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return RemindersCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      time: time ?? this.time,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('time: $time, ')
          ..write('status: $status, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CaregiverAlertsTable extends CaregiverAlerts
    with TableInfo<$CaregiverAlertsTable, CaregiverAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaregiverAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _alertIdMeta =
      const VerificationMeta('alertId');
  @override
  late final GeneratedColumn<String> alertId = GeneratedColumn<String>(
      'alert_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _triggerReasonMeta =
      const VerificationMeta('triggerReason');
  @override
  late final GeneratedColumn<String> triggerReason = GeneratedColumn<String>(
      'trigger_reason', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urgencyMeta =
      const VerificationMeta('urgency');
  @override
  late final GeneratedColumn<String> urgency = GeneratedColumn<String>(
      'urgency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [alertId, triggerReason, urgency, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'caregiver_alerts';
  @override
  VerificationContext validateIntegrity(Insertable<CaregiverAlert> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alert_id')) {
      context.handle(_alertIdMeta,
          alertId.isAcceptableOrUnknown(data['alert_id']!, _alertIdMeta));
    } else if (isInserting) {
      context.missing(_alertIdMeta);
    }
    if (data.containsKey('trigger_reason')) {
      context.handle(
          _triggerReasonMeta,
          triggerReason.isAcceptableOrUnknown(
              data['trigger_reason']!, _triggerReasonMeta));
    } else if (isInserting) {
      context.missing(_triggerReasonMeta);
    }
    if (data.containsKey('urgency')) {
      context.handle(_urgencyMeta,
          urgency.isAcceptableOrUnknown(data['urgency']!, _urgencyMeta));
    } else if (isInserting) {
      context.missing(_urgencyMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {alertId};
  @override
  CaregiverAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaregiverAlert(
      alertId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alert_id'])!,
      triggerReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger_reason'])!,
      urgency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}urgency'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $CaregiverAlertsTable createAlias(String alias) {
    return $CaregiverAlertsTable(attachedDatabase, alias);
  }
}

class CaregiverAlert extends DataClass implements Insertable<CaregiverAlert> {
  final String alertId;
  final String triggerReason;
  final String urgency;
  final DateTime timestamp;
  const CaregiverAlert(
      {required this.alertId,
      required this.triggerReason,
      required this.urgency,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alert_id'] = Variable<String>(alertId);
    map['trigger_reason'] = Variable<String>(triggerReason);
    map['urgency'] = Variable<String>(urgency);
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  CaregiverAlertsCompanion toCompanion(bool nullToAbsent) {
    return CaregiverAlertsCompanion(
      alertId: Value(alertId),
      triggerReason: Value(triggerReason),
      urgency: Value(urgency),
      timestamp: Value(timestamp),
    );
  }

  factory CaregiverAlert.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaregiverAlert(
      alertId: serializer.fromJson<String>(json['alertId']),
      triggerReason: serializer.fromJson<String>(json['triggerReason']),
      urgency: serializer.fromJson<String>(json['urgency']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'alertId': serializer.toJson<String>(alertId),
      'triggerReason': serializer.toJson<String>(triggerReason),
      'urgency': serializer.toJson<String>(urgency),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  CaregiverAlert copyWith(
          {String? alertId,
          String? triggerReason,
          String? urgency,
          DateTime? timestamp}) =>
      CaregiverAlert(
        alertId: alertId ?? this.alertId,
        triggerReason: triggerReason ?? this.triggerReason,
        urgency: urgency ?? this.urgency,
        timestamp: timestamp ?? this.timestamp,
      );
  CaregiverAlert copyWithCompanion(CaregiverAlertsCompanion data) {
    return CaregiverAlert(
      alertId: data.alertId.present ? data.alertId.value : this.alertId,
      triggerReason: data.triggerReason.present
          ? data.triggerReason.value
          : this.triggerReason,
      urgency: data.urgency.present ? data.urgency.value : this.urgency,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaregiverAlert(')
          ..write('alertId: $alertId, ')
          ..write('triggerReason: $triggerReason, ')
          ..write('urgency: $urgency, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(alertId, triggerReason, urgency, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaregiverAlert &&
          other.alertId == this.alertId &&
          other.triggerReason == this.triggerReason &&
          other.urgency == this.urgency &&
          other.timestamp == this.timestamp);
}

class CaregiverAlertsCompanion extends UpdateCompanion<CaregiverAlert> {
  final Value<String> alertId;
  final Value<String> triggerReason;
  final Value<String> urgency;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const CaregiverAlertsCompanion({
    this.alertId = const Value.absent(),
    this.triggerReason = const Value.absent(),
    this.urgency = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaregiverAlertsCompanion.insert({
    required String alertId,
    required String triggerReason,
    required String urgency,
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : alertId = Value(alertId),
        triggerReason = Value(triggerReason),
        urgency = Value(urgency);
  static Insertable<CaregiverAlert> custom({
    Expression<String>? alertId,
    Expression<String>? triggerReason,
    Expression<String>? urgency,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (alertId != null) 'alert_id': alertId,
      if (triggerReason != null) 'trigger_reason': triggerReason,
      if (urgency != null) 'urgency': urgency,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaregiverAlertsCompanion copyWith(
      {Value<String>? alertId,
      Value<String>? triggerReason,
      Value<String>? urgency,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
    return CaregiverAlertsCompanion(
      alertId: alertId ?? this.alertId,
      triggerReason: triggerReason ?? this.triggerReason,
      urgency: urgency ?? this.urgency,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (alertId.present) {
      map['alert_id'] = Variable<String>(alertId.value);
    }
    if (triggerReason.present) {
      map['trigger_reason'] = Variable<String>(triggerReason.value);
    }
    if (urgency.present) {
      map['urgency'] = Variable<String>(urgency.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaregiverAlertsCompanion(')
          ..write('alertId: $alertId, ')
          ..write('triggerReason: $triggerReason, ')
          ..write('urgency: $urgency, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $GameSessionsTable gameSessions = $GameSessionsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $CaregiverAlertsTable caregiverAlerts =
      $CaregiverAlertsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [users, gameSessions, reminders, caregiverAlerts];
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String name,
  Value<String> nativeLanguage,
  Value<String?> region,
  required String userType,
  Value<DateTime> createdAt,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> nativeLanguage,
  Value<String?> region,
  Value<String> userType,
  Value<DateTime> createdAt,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GameSessionsTable, List<GameSession>>
      _gameSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.gameSessions,
              aliasName: 'users__id__game_sessions__user_id');

  $$GameSessionsTableProcessedTableManager get gameSessionsRefs {
    final manager = $$GameSessionsTableTableManager($_db, $_db.gameSessions)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gameSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RemindersTable, List<Reminder>>
      _remindersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.reminders,
              aliasName: 'users__id__reminders__user_id');

  $$RemindersTableProcessedTableManager get remindersRefs {
    final manager = $$RemindersTableTableManager($_db, $_db.reminders)
        .filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nativeLanguage => $composableBuilder(
      column: $table.nativeLanguage,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userType => $composableBuilder(
      column: $table.userType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> gameSessionsRefs(
      Expression<bool> Function($$GameSessionsTableFilterComposer f) f) {
    final $$GameSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameSessions,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameSessionsTableFilterComposer(
              $db: $db,
              $table: $db.gameSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> remindersRefs(
      Expression<bool> Function($$RemindersTableFilterComposer f) f) {
    final $$RemindersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableFilterComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nativeLanguage => $composableBuilder(
      column: $table.nativeLanguage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get region => $composableBuilder(
      column: $table.region, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userType => $composableBuilder(
      column: $table.userType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nativeLanguage => $composableBuilder(
      column: $table.nativeLanguage, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get userType =>
      $composableBuilder(column: $table.userType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> gameSessionsRefs<T extends Object>(
      Expression<T> Function($$GameSessionsTableAnnotationComposer a) f) {
    final $$GameSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.gameSessions,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$GameSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.gameSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> remindersRefs<T extends Object>(
      Expression<T> Function($$RemindersTableAnnotationComposer a) f) {
    final $$RemindersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reminders,
        getReferencedColumn: (t) => t.userId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RemindersTableAnnotationComposer(
              $db: $db,
              $table: $db.reminders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool gameSessionsRefs, bool remindersRefs})> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nativeLanguage = const Value.absent(),
            Value<String?> region = const Value.absent(),
            Value<String> userType = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            name: name,
            nativeLanguage: nativeLanguage,
            region: region,
            userType: userType,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> nativeLanguage = const Value.absent(),
            Value<String?> region = const Value.absent(),
            required String userType,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            name: name,
            nativeLanguage: nativeLanguage,
            region: region,
            userType: userType,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$UsersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {gameSessionsRefs = false, remindersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (gameSessionsRefs) db.gameSessions,
                if (remindersRefs) db.reminders
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gameSessionsRefs)
                    await $_getPrefetchedData<User, $UsersTable, GameSession>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._gameSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0)
                                .gameSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items),
                  if (remindersRefs)
                    await $_getPrefetchedData<User, $UsersTable, Reminder>(
                        currentTable: table,
                        referencedTable:
                            $$UsersTableReferences._remindersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$UsersTableReferences(db, table, p0).remindersRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.userId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, $$UsersTableReferences),
    User,
    PrefetchHooks Function({bool gameSessionsRefs, bool remindersRefs})>;
typedef $$GameSessionsTableCreateCompanionBuilder = GameSessionsCompanion
    Function({
  required String id,
  required int userId,
  required String gameType,
  required int durationSeconds,
  required double difficultyLevel,
  required int reactionTimeMs,
  required double successRate,
  required double cvs,
  Value<DateTime> timestamp,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$GameSessionsTableUpdateCompanionBuilder = GameSessionsCompanion
    Function({
  Value<String> id,
  Value<int> userId,
  Value<String> gameType,
  Value<int> durationSeconds,
  Value<double> difficultyLevel,
  Value<int> reactionTimeMs,
  Value<double> successRate,
  Value<double> cvs,
  Value<DateTime> timestamp,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$GameSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession> {
  $$GameSessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('game_sessions__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$GameSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gameType => $composableBuilder(
      column: $table.gameType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difficultyLevel => $composableBuilder(
      column: $table.difficultyLevel,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reactionTimeMs => $composableBuilder(
      column: $table.reactionTimeMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get successRate => $composableBuilder(
      column: $table.successRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cvs => $composableBuilder(
      column: $table.cvs, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gameType => $composableBuilder(
      column: $table.gameType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difficultyLevel => $composableBuilder(
      column: $table.difficultyLevel,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reactionTimeMs => $composableBuilder(
      column: $table.reactionTimeMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get successRate => $composableBuilder(
      column: $table.successRate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cvs => $composableBuilder(
      column: $table.cvs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
      column: $table.durationSeconds, builder: (column) => column);

  GeneratedColumn<double> get difficultyLevel => $composableBuilder(
      column: $table.difficultyLevel, builder: (column) => column);

  GeneratedColumn<int> get reactionTimeMs => $composableBuilder(
      column: $table.reactionTimeMs, builder: (column) => column);

  GeneratedColumn<double> get successRate => $composableBuilder(
      column: $table.successRate, builder: (column) => column);

  GeneratedColumn<double> get cvs =>
      $composableBuilder(column: $table.cvs, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$GameSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GameSessionsTable,
    GameSession,
    $$GameSessionsTableFilterComposer,
    $$GameSessionsTableOrderingComposer,
    $$GameSessionsTableAnnotationComposer,
    $$GameSessionsTableCreateCompanionBuilder,
    $$GameSessionsTableUpdateCompanionBuilder,
    (GameSession, $$GameSessionsTableReferences),
    GameSession,
    PrefetchHooks Function({bool userId})> {
  $$GameSessionsTableTableManager(_$AppDatabase db, $GameSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> gameType = const Value.absent(),
            Value<int> durationSeconds = const Value.absent(),
            Value<double> difficultyLevel = const Value.absent(),
            Value<int> reactionTimeMs = const Value.absent(),
            Value<double> successRate = const Value.absent(),
            Value<double> cvs = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameSessionsCompanion(
            id: id,
            userId: userId,
            gameType: gameType,
            durationSeconds: durationSeconds,
            difficultyLevel: difficultyLevel,
            reactionTimeMs: reactionTimeMs,
            successRate: successRate,
            cvs: cvs,
            timestamp: timestamp,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int userId,
            required String gameType,
            required int durationSeconds,
            required double difficultyLevel,
            required int reactionTimeMs,
            required double successRate,
            required double cvs,
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GameSessionsCompanion.insert(
            id: id,
            userId: userId,
            gameType: gameType,
            durationSeconds: durationSeconds,
            difficultyLevel: difficultyLevel,
            reactionTimeMs: reactionTimeMs,
            successRate: successRate,
            cvs: cvs,
            timestamp: timestamp,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$GameSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$GameSessionsTableReferences._userIdTable(db),
                    referencedColumn:
                        $$GameSessionsTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$GameSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GameSessionsTable,
    GameSession,
    $$GameSessionsTableFilterComposer,
    $$GameSessionsTableOrderingComposer,
    $$GameSessionsTableAnnotationComposer,
    $$GameSessionsTableCreateCompanionBuilder,
    $$GameSessionsTableUpdateCompanionBuilder,
    (GameSession, $$GameSessionsTableReferences),
    GameSession,
    PrefetchHooks Function({bool userId})>;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String id,
  required int userId,
  required String type,
  required DateTime time,
  Value<String> status,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> id,
  Value<int> userId,
  Value<String> type,
  Value<DateTime> time,
  Value<String> status,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$RemindersTableReferences
    extends BaseReferences<_$AppDatabase, $RemindersTable, Reminder> {
  $$RemindersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('reminders__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager($_db, $_db.users)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableFilterComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableOrderingComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.userId,
        referencedTable: $db.users,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UsersTableAnnotationComposer(
              $db: $db,
              $table: $db.users,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RemindersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, $$RemindersTableReferences),
    Reminder,
    PrefetchHooks Function({bool userId})> {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> userId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersCompanion(
            id: id,
            userId: userId,
            type: type,
            time: time,
            status: status,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int userId,
            required String type,
            required DateTime time,
            Value<String> status = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RemindersCompanion.insert(
            id: id,
            userId: userId,
            type: type,
            time: time,
            status: status,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RemindersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (userId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.userId,
                    referencedTable:
                        $$RemindersTableReferences._userIdTable(db),
                    referencedColumn:
                        $$RemindersTableReferences._userIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, $$RemindersTableReferences),
    Reminder,
    PrefetchHooks Function({bool userId})>;
typedef $$CaregiverAlertsTableCreateCompanionBuilder = CaregiverAlertsCompanion
    Function({
  required String alertId,
  required String triggerReason,
  required String urgency,
  Value<DateTime> timestamp,
  Value<int> rowid,
});
typedef $$CaregiverAlertsTableUpdateCompanionBuilder = CaregiverAlertsCompanion
    Function({
  Value<String> alertId,
  Value<String> triggerReason,
  Value<String> urgency,
  Value<DateTime> timestamp,
  Value<int> rowid,
});

class $$CaregiverAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $CaregiverAlertsTable> {
  $$CaregiverAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get alertId => $composableBuilder(
      column: $table.alertId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triggerReason => $composableBuilder(
      column: $table.triggerReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get urgency => $composableBuilder(
      column: $table.urgency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$CaregiverAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaregiverAlertsTable> {
  $$CaregiverAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get alertId => $composableBuilder(
      column: $table.alertId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triggerReason => $composableBuilder(
      column: $table.triggerReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get urgency => $composableBuilder(
      column: $table.urgency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$CaregiverAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaregiverAlertsTable> {
  $$CaregiverAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get alertId =>
      $composableBuilder(column: $table.alertId, builder: (column) => column);

  GeneratedColumn<String> get triggerReason => $composableBuilder(
      column: $table.triggerReason, builder: (column) => column);

  GeneratedColumn<String> get urgency =>
      $composableBuilder(column: $table.urgency, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$CaregiverAlertsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CaregiverAlertsTable,
    CaregiverAlert,
    $$CaregiverAlertsTableFilterComposer,
    $$CaregiverAlertsTableOrderingComposer,
    $$CaregiverAlertsTableAnnotationComposer,
    $$CaregiverAlertsTableCreateCompanionBuilder,
    $$CaregiverAlertsTableUpdateCompanionBuilder,
    (
      CaregiverAlert,
      BaseReferences<_$AppDatabase, $CaregiverAlertsTable, CaregiverAlert>
    ),
    CaregiverAlert,
    PrefetchHooks Function()> {
  $$CaregiverAlertsTableTableManager(
      _$AppDatabase db, $CaregiverAlertsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaregiverAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaregiverAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaregiverAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> alertId = const Value.absent(),
            Value<String> triggerReason = const Value.absent(),
            Value<String> urgency = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaregiverAlertsCompanion(
            alertId: alertId,
            triggerReason: triggerReason,
            urgency: urgency,
            timestamp: timestamp,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String alertId,
            required String triggerReason,
            required String urgency,
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaregiverAlertsCompanion.insert(
            alertId: alertId,
            triggerReason: triggerReason,
            urgency: urgency,
            timestamp: timestamp,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CaregiverAlertsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CaregiverAlertsTable,
    CaregiverAlert,
    $$CaregiverAlertsTableFilterComposer,
    $$CaregiverAlertsTableOrderingComposer,
    $$CaregiverAlertsTableAnnotationComposer,
    $$CaregiverAlertsTableCreateCompanionBuilder,
    $$CaregiverAlertsTableUpdateCompanionBuilder,
    (
      CaregiverAlert,
      BaseReferences<_$AppDatabase, $CaregiverAlertsTable, CaregiverAlert>
    ),
    CaregiverAlert,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$GameSessionsTableTableManager get gameSessions =>
      $$GameSessionsTableTableManager(_db, _db.gameSessions);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$CaregiverAlertsTableTableManager get caregiverAlerts =>
      $$CaregiverAlertsTableTableManager(_db, _db.caregiverAlerts);
}
