class DatabaseTables {
  static const String databaseName = 'nuanyu.db';
  static const int databaseVersion = 1;

  static const String tableMoodEntries = 'mood_entries';
  static const String tableSymptomRecords = 'symptom_records';
  static const String tableJournalEntries = 'journal_entries';
  static const String tableSelfCareItems = 'self_care_items';

  static const String createMoodEntries = '''
    CREATE TABLE $tableMoodEntries (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      mood_score INTEGER NOT NULL,
      emotion_label TEXT,
      note TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static const String createSymptomRecords = '''
    CREATE TABLE $tableSymptomRecords (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      symptom_type TEXT NOT NULL,
      intensity INTEGER NOT NULL,
      trigger TEXT,
      note TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static const String createJournalEntries = '''
    CREATE TABLE $tableJournalEntries (
      id TEXT PRIMARY KEY,
      date TEXT NOT NULL,
      time TEXT NOT NULL,
      content TEXT NOT NULL,
      mood_score INTEGER,
      created_at TEXT NOT NULL,
      updated_at TEXT
    )
  ''';

  static const String createSelfCareItems = '''
    CREATE TABLE $tableSelfCareItems (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      duration_minutes INTEGER NOT NULL DEFAULT 5,
      is_completed_today INTEGER NOT NULL DEFAULT 0,
      last_completed_date TEXT,
      created_at TEXT NOT NULL
    )
  ''';

  static List<String> get createStatements => [
    createMoodEntries,
    createSymptomRecords,
    createJournalEntries,
    createSelfCareItems,
  ];
}
