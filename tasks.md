---
description: "Task list for 暖屿 (NuanYu) — CPTSD 自我管理 Flutter 应用"
---

# Tasks: 暖屿 (NuanYu)

**Input**: Design documents from project root (`plan.txt`)

**Tech Stack**: Flutter 3.22 · Riverpod · sqflite · go_router · fl_chart · local_auth · 纯离线 Android

**Tests**: Not requested — no test tasks included.

**Organization**: Tasks grouped by feature/user story, dependency-ordered within each phase.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4, US5)
- All paths are relative to the Flutter project root `nuanyu/`

---

## Phase 1: Setup — 项目初始化

**Purpose**: Scaffold the Flutter project, configure dependencies, offline security, and the foundational theme/widget/routing layer.

- [X] T001 Create Flutter project via `flutter create nuanyu` with org/package name, target Android only
- [X] T002 [P] Configure `nuanyu/pubspec.yaml` with all dependencies: flutter_riverpod, riverpod_annotation, go_router, sqflite, local_auth, fl_chart, uuid, path_provider, intl, plus dev deps riverpod_generator, build_runner, flutter_lints
- [X] T003 [P] Remove INTERNET permission from `nuanyu/android/app/src/main/AndroidManifest.xml`, set `android:usesCleartextTraffic="false"`
- [X] T004 [P] Set minSdkVersion 21 and targetSdkVersion in `nuanyu/android/app/build.gradle`
- [X] T005 [P] Create theme color constants in `nuanyu/lib/core/constants/app_colors.dart` per plan.md color scheme (珊瑚主色 `#F5A08C`, 米白背景 `#FFF8F2`, 情绪渐变四级)
- [X] T006 [P] Create all Chinese string constants in `nuanyu/lib/core/constants/app_strings.dart` (tab labels, button text, emotion labels, symptom types, breathing mode names, affirmations, empty states)
- [X] T007 [P] Create dimension/spacing/radius constants in `nuanyu/lib/core/constants/app_dimensions.dart`
- [X] T008 Create ThemeData definition in `nuanyu/lib/core/theme/app_theme.dart` using app_colors (暖色调 Material 3 theme, card/button/scaffold styles)
- [X] T009 [P] Create WarmScaffold wrapper in `nuanyu/lib/core/widgets/warm_scaffold.dart` (warm background color, safe area)
- [X] T010 [P] Create WarmCard widget in `nuanyu/lib/core/widgets/warm_card.dart` (rounded card with shadow, white background)
- [X] T011 [P] Create SoothingButton widget in `nuanyu/lib/core/widgets/soothing_button.dart` (press-scale animation, warm color transitions)
- [X] T012 [P] Create MoodIndicator dot widget in `nuanyu/lib/core/widgets/mood_indicator.dart` (colored circle keyed to mood score 1-10)
- [X] T013 [P] Create EmptyState illustration widget in `nuanyu/lib/core/widgets/empty_state.dart` (placeholder with warm text)
- [X] T014 [P] Create date formatting utilities in `nuanyu/lib/core/utils/date_utils.dart` (yyyy-MM-dd, HH:mm, relative day labels)
- [X] T015 [P] Create mood-to-color/emoji mapping utilities in `nuanyu/lib/core/utils/mood_utils.dart` (1-3 淡紫, 4-6 淡杏, 7-8 暖珊瑚, 9-10 暖金黄)
- [X] T016 Create GoRouter config and bottom navigation shell in `nuanyu/lib/routes.dart` (4 tabs: 呼吸 Tab 0 default, 情绪 Tab 1, 关怀 Tab 2, 日记 Tab 3; settings as sub-route)
- [X] T017 Create `nuanyu/lib/app.dart` — MaterialApp.router with GoRouter, theme, Chinese locale
- [X] T018 Create `nuanyu/lib/main.dart` — entry point: WidgetsFlutterBinding, Riverpod ProviderScope, run app

**Checkpoint**: Flutter project compiles with 4-tab bottom navigation, warm theme applied, all constants and shared widgets available.

---

## Phase 2: Foundational — 数据层 + 应用锁

**Purpose**: Database schema, models, repositories, and biometric auth lock. BLOCKS all user stories.

**⚠️ CRITICAL**: No feature work can begin until this phase is complete.

- [X] T019 [P] Create MoodEntry model in `nuanyu/lib/data/models/mood_entry.dart` (id, date, time, moodScore, emotionLabel, note, createdAt; fromJson/toJson)
- [X] T020 [P] Create SymptomRecord model in `nuanyu/lib/data/models/symptom_record.dart` (id, date, time, symptomType, intensity, trigger, note, createdAt)
- [X] T021 [P] Create JournalEntry model in `nuanyu/lib/data/models/journal_entry.dart` (id, date, time, content, moodScore, createdAt, updatedAt)
- [X] T022 [P] Create SelfCareItem model in `nuanyu/lib/data/models/self_care_item.dart` (id, title, description, durationMinutes, isCompletedToday, lastCompletedDate, createdAt)
- [X] T023 Create table name/column constants in `nuanyu/lib/data/database/database_tables.dart` for all 4 tables per plan.md schema
- [X] T024 Create DatabaseHelper in `nuanyu/lib/data/database/database_helper.dart` — sqflite init, onCreate with all 4 CREATE TABLE statements, onUpgrade migration skeleton
- [X] T025 [P] Create MoodRepository in `nuanyu/lib/data/repositories/mood_repository.dart` — CRUD: insert, getAll, getByDateRange, getById, update, delete
- [X] T026 [P] Create SymptomRepository in `nuanyu/lib/data/repositories/symptom_repository.dart` — CRUD: insert, getAll, getByDateRange, getById, update, delete
- [X] T027 [P] Create JournalRepository in `nuanyu/lib/data/repositories/journal_repository.dart` — CRUD: insert, getAll, getByDateRange, getById, update, delete
- [X] T028 [P] Create SelfCareRepository in `nuanyu/lib/data/repositories/self_care_repository.dart` — CRUD: insert, getAll, getById, update, delete, markCompletedToday with date reset logic
- [X] T029 Create AuthProvider (Riverpod) in `nuanyu/lib/features/auth_lock/auth_provider.dart` — wraps local_auth: check biometric availability, authenticate, isLocked state
- [X] T030 Create AuthLockScreen in `nuanyu/lib/features/auth_lock/auth_lock_screen.dart` — full-screen lock with biometric trigger, WidgetsBindingObserver for app lifecycle re-auth

**Checkpoint**: Database fully operational with all 4 repositories tested via quick insert/read. Biometric auth gate working on app launch and resume.

---

## Phase 3: User Story 1 — 呼吸练习 (Breathing Exercises, P1) 🎯 MVP

**Goal**: User opens the app (default tab) and can select a breathing pattern, follow a guided animated session with haptic feedback, and receive completion encouragement.

**Independent Test**: Launch app → authenticate → default breathing tab shows → select a pattern → tap start → follow breathing animation cycle → complete → see encouragement.

### Implementation for User Story 1

- [X] T031 [US1] Create BreathingProvider (Riverpod) in `nuanyu/lib/features/breathing/providers/breathing_provider.dart` — state: selected pattern, session phase (inhale/hold/exhale/rest), elapsed seconds, cycle count, isRunning, isPaused; actions: start, pause, resume, reset; pre-configure 4 preset breathing patterns (4-7-8, 方块, 4-4-4, 2-4-6)
- [X] T032 [US1] Create BreathingAnimation widget in `nuanyu/lib/features/breathing/breathing_animation.dart` — CustomPainter circle that scales with breath phase (inhale=expand, hold=steady, exhale=shrink) using Curves.easeInOut, color transitions matching breath phase
- [X] T033 [US1] Create BreathingPage in `nuanyu/lib/features/breathing/breathing_page.dart` — pattern selection cards (name + description + icon), start button, settings gear icon in top-right
- [X] T034 [US1] Create BreathingSession in `nuanyu/lib/features/breathing/breathing_session.dart` — full guided flow: countdown start, phase indicator text (吸气/屏息/呼气), breathing animation, progress ring/bar, pause/resume/reset controls, HapticFeedback.heavyImpact() on phase transitions
- [X] T035 [US1] Create BreathingComplete in `nuanyu/lib/features/breathing/breathing_complete.dart` — completion screen with warm congratulation text, cycle count summary, "再来一次" and "返回" buttons

**Checkpoint**: Breathing feature fully functional — select pattern, guided session with animation and haptics, completion screen.

---

## Phase 4: User Story 2 — 情绪追踪 (Mood Tracking, P2)

**Goal**: User can record daily mood on a 1-10 scale with emotion labels and notes, browse history in calendar and list views, and view mood trend charts.

**Independent Test**: Navigate to 情绪 tab → see calendar with mood dots → tap a date → record mood via slider + labels + note → see entry in list → view trend chart.

### Implementation for User Story 2

- [ ] T036 [US2] Create MoodProvider (Riverpod) in `nuanyu/lib/features/mood_tracker/providers/mood_provider.dart` — state: entries list (filtered by selected date/week/month), selectedDate; actions: loadByDate, loadByDateRange, addEntry, updateEntry, deleteEntry; integrate MoodRepository
- [ ] T037 [US2] Create MoodTrackerPage in `nuanyu/lib/features/mood_tracker/mood_tracker_page.dart` — monthly calendar grid with mood-color dots per day, tap day to view/add entry, today summary card at top
- [ ] T038 [US2] Create MoodRecordSheet in `nuanyu/lib/features/mood_tracker/mood_record_sheet.dart` — bottom sheet: mood score slider 1-10 (with color gradient), emotion label chip selector (14 presets), optional note TextField, save/cancel buttons
- [ ] T039 [US2] Create MoodDetailPage in `nuanyu/lib/features/mood_tracker/mood_detail_page.dart` — read-only view of a single entry: score with color indicator, emotion label, note, date/time; edit/delete actions
- [ ] T040 [US2] Create MoodTrendChart in `nuanyu/lib/features/mood_tracker/mood_trend_chart.dart` — fl_chart LineChart: x-axis dates, y-axis 1-10, color-coded line, week/month toggle, average mood line overlay

**Checkpoint**: Mood tracking fully functional — record, browse history, view trend charts with week/month toggle.

---

## Phase 5: User Story 3 — 自我关怀 (Self Care, P3)

**Goal**: User can create personalized self-care items with suggested duration, check off daily completion, use a guided timer, and receive random daily affirmations.

**Independent Test**: Navigate to 关怀 tab → see care item list with completion checkboxes → add custom item → start timer for an item → complete → see affirmation.

### Implementation for User Story 3

- [ ] T041 [US3] Create SelfCareProvider (Riverpod) in `nuanyu/lib/features/self_care/providers/self_care_provider.dart` — state: items list, daily affirmation; actions: loadItems, addItem, updateItem, deleteItem, toggleCompletedToday, resetDailyCompletions (date-change logic); seed 6 preset care items (喝水, 散步, 感恩, 听歌, 浇花, 深呼吸)
- [ ] T042 [US3] Create SelfCarePage in `nuanyu/lib/features/self_care/self_care_page.dart` — list of care items with checkbox (今日完成), item title + duration, swipe-to-delete, FAB to add new, daily affirmation banner at top
- [ ] T043 [US3] Create AddCareItemPage in `nuanyu/lib/features/self_care/add_care_item_page.dart` — form: title, description (optional), duration_minutes picker (5-60 min stepper), save button
- [ ] T044 [US3] Create CareTimerPage in `nuanyu/lib/features/self_care/care_timer_page.dart` — countdown timer with circular progress, pause/resume, completion celebration with HapticFeedback, "标记完成" button
- [ ] T045 [US3] Create DailyAffirmation widget in `nuanyu/lib/features/self_care/daily_affirmation.dart` — random affirmation from 12 presets (Chinese warm affirmations), refreshes daily, warm card styling

**Checkpoint**: Self care fully functional — CRUD items, daily check-off, guided timer, daily affirmations.

---

## Phase 6: User Story 4 — 日记记录 (Journal, P4)

**Goal**: User can write, edit, and browse journal entries organized by date, with optional mood score association.

**Independent Test**: Navigate to 日记 tab → see entries grouped by date → tap to read → tap + to create → write text + optionally link mood → save → see in list.

### Implementation for User Story 4

- [ ] T046 [US4] Create JournalProvider (Riverpod) in `nuanyu/lib/features/journal/providers/journal_provider.dart` — state: entries grouped by date, selectedEntry; actions: loadAll (grouped), getById, addEntry, updateEntry, deleteEntry; integrate JournalRepository
- [ ] T047 [US4] Create JournalListPage in `nuanyu/lib/features/journal/journal_list_page.dart` — entries grouped by date sections with headers, each entry showing preview text + mood color dot + time, FAB to add new
- [ ] T048 [US4] Create JournalEditPage in `nuanyu/lib/features/journal/journal_edit_page.dart` — full-screen text editor, optional mood score picker (1-10), save with auto date/time, back-confirm discard dialog
- [ ] T049 [US4] Create JournalDetailPage in `nuanyu/lib/features/journal/journal_detail_page.dart` — read-only rich view of entry: full content, mood indicator, date/time, edit button (navigates to edit page), delete with confirmation dialog

**Checkpoint**: Journal fully functional — create, read, update, delete entries with date grouping and mood association.

---

## Phase 7: User Story 5 — 设置与数据导出 (Settings & Export, P5)

**Goal**: User can access settings, export all app data as a JSON file, and view app information.

**Independent Test**: Tap gear icon → see settings page → tap 导出数据 → JSON file saved to Downloads → verify file contents.

### Implementation for User Story 5

- [ ] T050 [US5] Create SettingsProvider (Riverpod) in `nuanyu/lib/settings/providers/settings_provider.dart` — state: exportStatus (idle/exporting/done/error); actions: exportAllData (aggregates all 4 repositories into JSON)
- [ ] T051 [US5] Create JSON data export logic in `nuanyu/lib/core/utils/export_utils.dart` — aggregate mood_entries, symptom_records, journal_entries, self_care_items into structured JSON; write to Downloads directory via path_provider + dart:io; return file path
- [ ] T052 [US5] Create SettingsPage in `nuanyu/lib/settings/settings_page.dart` — list tiles: 导出全部数据 (with status indicator), 关于暖屿 (app version, description), 生物验证锁 toggle (enable/disable)

**Checkpoint**: Settings accessible from breathing tab, JSON export works end-to-end.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Animations, visual polish, edge cases, and final build.

- [ ] T053 [P] Add page transition animations in `nuanyu/lib/routes.dart` — fade and slide transitions for sub-routes (GoRouter page builders with CustomTransitionPage)
- [ ] T054 [P] Polish empty-state illustrations and warm placeholder text across all 4 tab pages — update empty_state.dart usages in mood_tracker_page, self_care_page, journal_list_page
- [ ] T055 [P] Refine micro-interactions: button press-scale feedback, card tap shadows, smooth scroll physics across all feature pages
- [ ] T056 [P] Add daily reset logic — at app launch or date change, reset `is_completed_today` on all self_care_items in `nuanyu/lib/data/repositories/self_care_repository.dart`
- [ ] T057 Final integration pass — verify all 4 tabs navigate correctly, data flows end-to-end, no console errors, warm theme consistent everywhere
- [ ] T058 Build release APK — `flutter build apk --release` in nuanyu/, verify APK output

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — BLOCKS all user stories
- **US1 呼吸 (Phase 3)**: Depends on Phase 2 — no other story dependencies
- **US2 情绪 (Phase 4)**: Depends on Phase 2 — independently testable from US1
- **US3 关怀 (Phase 5)**: Depends on Phase 2 — independently testable from US1/US2
- **US4 日记 (Phase 6)**: Depends on Phase 2 — independently testable from US1/US2/US3
- **US5 设置 (Phase 7)**: Depends on Phase 2 + all repositories from Phase 2 — aggregate export needs all data
- **Polish (Phase 8)**: Depends on all user stories being complete

### Within Each User Story

- Provider first (Riverpod state management)
- UI pages after provider is defined
- Widgets/animations before pages that use them
- Story complete before moving to next priority

### Parallel Opportunities

- **Phase 1**: T002–T007, T009–T015 all [P] — can run in parallel
- **Phase 2**: T019–T022 (models) all [P]; T025–T028 (repositories) all [P] after T024
- **Phase 3–6**: Once Phase 2 is done, US1–US4 can be built in parallel by different developers
- **Phase 8**: T053–T056 all [P] — can run in parallel

---

## Parallel Example: Phase 2 Foundational

```bash
# Launch all 4 models together:
Task: "Create MoodEntry model in nuanyu/lib/data/models/mood_entry.dart"
Task: "Create SymptomRecord model in nuanyu/lib/data/models/symptom_record.dart"
Task: "Create JournalEntry model in nuanyu/lib/data/models/journal_entry.dart"
Task: "Create SelfCareItem model in nuanyu/lib/data/models/self_care_item.dart"

# After T024 (DatabaseHelper), launch all 4 repositories together:
Task: "Create MoodRepository in nuanyu/lib/data/repositories/mood_repository.dart"
Task: "Create SymptomRepository in nuanyu/lib/data/repositories/symptom_repository.dart"
Task: "Create JournalRepository in nuanyu/lib/data/repositories/journal_repository.dart"
Task: "Create SelfCareRepository in nuanyu/lib/data/repositories/self_care_repository.dart"
```

---

## Implementation Strategy

### MVP First (US1 Only — 呼吸练习)

1. Complete Phase 1: Setup — project scaffolding, theme, routing
2. Complete Phase 2: Foundational — database + auth lock
3. Complete Phase 3: US1 呼吸练习 (Breathing)
4. **STOP and VALIDATE**: Breathing feature fully functional, app launches with auth lock
5. This is the MVP — the default landing tab works end-to-end

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. Add US1 呼吸 → Test independently → MVP!
3. Add US2 情绪 → Test independently → Mood tracking live
4. Add US3 关怀 → Test independently → Self care live
5. Add US4 日记 → Test independently → Journal live
6. Add US5 设置 → Test export → Settings complete
7. Polish → Release APK

### Parallel Team Strategy

With multiple developers after Phase 2:

- Developer A: US1 呼吸 (Breathing)
- Developer B: US2 情绪 (Mood Tracker)
- Developer C: US3 关怀 (Self Care)
- Developer D: US4 日记 (Journal)

US5 设置 requires all repositories, so it runs after all US1–US4.

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- No test tasks included (tests not requested in specification)
- All paths relative to `nuanyu/` Flutter project root
- Default app language: 简体中文 (hardcoded strings, no i18n)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently


