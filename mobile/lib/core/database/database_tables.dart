// Copyright (c) 2026 Team laccha paratha (SIH 2026). All rights reserved.
/*
 * Copyright (c) 2026 Team laccha paratha (Adarsh A, Twinkle B, Kashish, Utkarsh, Pratibha, Akash).
 * All rights reserved.
 * SMRITIVAN (स्मृतिवन) - SIH 2026 Problem Statement ID: 26003
 * Cognitive Gaming & Memory Assistance Platform for Dementia Patients in NER.
 */

/// Database table and column constants with CRDT columns for offline synchronization
class DbTables {
  DbTables._();

  // Table Names
  static const String users = 'users';
  static const String gameSessions = 'game_sessions';
  static const String reminders = 'reminders';
  static const String caregiverAlerts = 'caregiver_alerts';
  static const String caregivers = 'caregivers';
  static const String caregiverPatientRelationships = 'caregiver_patient_relationships';
  static const String crdtSyncLog = 'crdt_sync_log';

  // Common CRDT Tracking Columns
  static const String colHlcTimestamp = 'hlc_timestamp';
  static const String colIsDeleted = 'is_deleted';
  static const String colSyncStatus = 'sync_status'; // 'pending', 'synced', 'conflict_resolved'

  static const String createUsersTable = '''
    CREATE TABLE IF NOT EXISTS $users (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      native_language TEXT NOT NULL,
      dementia_stage TEXT NOT NULL,
      caregiver_id TEXT,
      age INTEGER,
      phone TEXT,
      preferred_activity_time TEXT,
      notifications_enabled INTEGER NOT NULL DEFAULT 1,
      profile_photo_path TEXT,
      sound_effects_enabled INTEGER NOT NULL DEFAULT 1,
      voice_guidance_enabled INTEGER NOT NULL DEFAULT 1,
      haptic_feedback_enabled INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      $colHlcTimestamp TEXT NOT NULL,
      $colIsDeleted INTEGER NOT NULL DEFAULT 0,
      $colSyncStatus TEXT NOT NULL DEFAULT 'pending'
    );
  ''';

  // Game Sessions Table
  static const String createGameSessionsTable = '''
    CREATE TABLE IF NOT EXISTS $gameSessions (
      session_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      game_type TEXT NOT NULL,
      duration_seconds INTEGER NOT NULL,
      difficulty_level REAL NOT NULL,
      reaction_time_ms INTEGER NOT NULL,
      error_rate REAL NOT NULL,
      cvs_score REAL NOT NULL,
      timestamp TEXT NOT NULL,
      $colSyncStatus TEXT NOT NULL DEFAULT 'pending',
      $colHlcTimestamp TEXT NOT NULL,
      $colIsDeleted INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES $users(id) ON DELETE CASCADE
    );
  ''';

  // Reminders Table (Expanded)
  static const String createRemindersTable = '''
    CREATE TABLE IF NOT EXISTS $reminders (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      type TEXT NOT NULL,
      category TEXT,
      priority TEXT NOT NULL DEFAULT 'normal',
      time TEXT NOT NULL,
      asset_url TEXT,
      status TEXT NOT NULL DEFAULT 'pending',
      completed_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      $colHlcTimestamp TEXT NOT NULL,
      $colIsDeleted INTEGER NOT NULL DEFAULT 0,
      $colSyncStatus TEXT NOT NULL DEFAULT 'pending',
      FOREIGN KEY (user_id) REFERENCES $users(id) ON DELETE CASCADE
    );
  ''';

  // Wellbeing Check-ins Table
  static const String wellbeingCheckins = 'wellbeing_checkins';
  
  static const String createWellbeingTable = '''
    CREATE TABLE IF NOT EXISTS $wellbeingCheckins (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      status TEXT NOT NULL,
      notes TEXT,
      timestamp TEXT NOT NULL,
      $colSyncStatus TEXT NOT NULL DEFAULT 'pending',
      $colHlcTimestamp TEXT NOT NULL,
      $colIsDeleted INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY (user_id) REFERENCES $users(id) ON DELETE CASCADE
    );
  ''';

  // Caregiver Alerts Table
  static const String createCaregiverAlertsTable = '''
    CREATE TABLE IF NOT EXISTS $caregiverAlerts (
      alert_id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL,
      category TEXT NOT NULL,
      urgency TEXT NOT NULL,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      suggested_action TEXT,
      status TEXT NOT NULL DEFAULT 'new',
      occurrences INTEGER NOT NULL DEFAULT 1,
      first_detected TEXT NOT NULL,
      last_updated TEXT NOT NULL,
      $colSyncStatus TEXT NOT NULL DEFAULT 'pending',
      $colHlcTimestamp TEXT NOT NULL,
      $colIsDeleted INTEGER NOT NULL DEFAULT 0
    );
  ''';

  // Caregivers Table
  static const String createCaregiversTable = '''
    CREATE TABLE IF NOT EXISTS $caregivers (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      profile_photo_path TEXT,
      $colHlcTimestamp TEXT NOT NULL,
      $colIsDeleted INTEGER NOT NULL DEFAULT 0,
      $colSyncStatus TEXT NOT NULL DEFAULT 'pending'
    );
  ''';

  // Caregiver Patient Relationships Table
  static const String createRelationshipsTable = '''
    CREATE TABLE IF NOT EXISTS $caregiverPatientRelationships (
      rel_id TEXT PRIMARY KEY,
      patient_id TEXT NOT NULL,
      caregiver_id TEXT NOT NULL,
      relationship_type TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      $colHlcTimestamp TEXT NOT NULL,
      $colIsDeleted INTEGER NOT NULL DEFAULT 0,
      $colSyncStatus TEXT NOT NULL DEFAULT 'pending',
      FOREIGN KEY (patient_id) REFERENCES $users(id) ON DELETE CASCADE,
      FOREIGN KEY (caregiver_id) REFERENCES $caregivers(id) ON DELETE CASCADE
    );
  ''';

  // CRDT Sync Log for Delta Replication
  static const String createCrdtSyncLogTable = '''
    CREATE TABLE IF NOT EXISTS $crdtSyncLog (
      log_id TEXT PRIMARY KEY,
      table_name TEXT NOT NULL,
      row_id TEXT NOT NULL,
      operation TEXT NOT NULL,
      payload_json TEXT NOT NULL,
      hlc_timestamp TEXT NOT NULL,
      synced_at TEXT
    );
  ''';

  // Indexes for high-speed local analytics & querying
  static const List<String> createIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_game_sessions_user_time ON $gameSessions(user_id, timestamp);',
    'CREATE INDEX IF NOT EXISTS idx_reminders_user_status ON $reminders(user_id, status);',
    'CREATE INDEX IF NOT EXISTS idx_caregiver_alerts_urgency ON $caregiverAlerts(urgency, last_updated);',
    'CREATE INDEX IF NOT EXISTS idx_cpr_patient ON $caregiverPatientRelationships(patient_id, status);',
    'CREATE INDEX IF NOT EXISTS idx_crdt_sync_hlc ON $crdtSyncLog(hlc_timestamp);',
  ];
}

