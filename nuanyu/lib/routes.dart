import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/breathing/breathing_page.dart';
import 'features/breathing/breathing_session.dart';
import 'features/breathing/breathing_complete.dart';
import 'features/mood_tracker/mood_tracker_page.dart';
import 'features/mood_tracker/mood_detail_page.dart';
import 'features/mood_tracker/mood_trend_chart.dart';
import 'features/self_care/self_care_page.dart';
import 'features/self_care/add_care_item_page.dart';
import 'features/self_care/care_timer_page.dart';
import 'features/journal/journal_list_page.dart';
import 'features/journal/journal_edit_page.dart';
import 'features/journal/journal_detail_page.dart';
import 'settings/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey1 = GlobalKey<NavigatorState>();
final _shellNavigatorKey2 = GlobalKey<NavigatorState>();
final _shellNavigatorKey3 = GlobalKey<NavigatorState>();
final _shellNavigatorKey4 = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/breathing',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey1,
          routes: [
            GoRoute(
              path: '/breathing',
              builder: (context, state) => const BreathingPage(),
              routes: [
                GoRoute(
                  path: 'session',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const BreathingSession(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                ),
                GoRoute(
                  path: 'complete',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const BreathingComplete(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey2,
          routes: [
            GoRoute(
              path: '/mood',
              builder: (context, state) => const MoodTrackerPage(),
              routes: [
                GoRoute(
                  path: 'detail/:entryId',
                  builder: (context, state) => MoodDetailPage(
                    entryId: state.pathParameters['entryId']!,
                  ),
                ),
                GoRoute(
                  path: 'trend',
                  builder: (context, state) => const MoodTrendChart(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey3,
          routes: [
            GoRoute(
              path: '/selfcare',
              builder: (context, state) => const SelfCarePage(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddCareItemPage(),
                ),
                GoRoute(
                  path: 'timer/:itemId',
                  builder: (context, state) => CareTimerPage(
                    itemId: state.pathParameters['itemId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorKey4,
          routes: [
            GoRoute(
              path: '/journal',
              builder: (context, state) => const JournalListPage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const JournalEditPage(),
                ),
                GoRoute(
                  path: 'edit/:entryId',
                  builder: (context, state) => const JournalEditPage(),
                ),
                GoRoute(
                  path: 'detail/:entryId',
                  builder: (context, state) => JournalDetailPage(
                    entryId: state.pathParameters['entryId']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.spa_outlined),
            selectedIcon: Icon(Icons.spa),
            label: '呼吸',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: '情绪',
          ),
          NavigationDestination(
            icon: Icon(Icons.self_improvement_outlined),
            selectedIcon: Icon(Icons.self_improvement),
            label: '关怀',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: '日记',
          ),
        ],
      ),
    );
  }
}
