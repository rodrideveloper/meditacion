import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/services/review_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/attention_thread.dart';
import '../bloc/meditation_bloc.dart';
import '../bloc/meditation_event.dart';
import '../bloc/meditation_state.dart';
import '../widgets/duration_picker.dart';
import '../widgets/meditation_button.dart';
import 'history_page.dart';
import 'meditation_page.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<MeditationBloc>()..add(const LoadSettingsEvent()),
    child: const _HomeShell(),
  );
}

class _HomeShell extends StatefulWidget {
  const _HomeShell();
  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _tab,
      children: const [_PracticePage(), HistoryPage()],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (index) => setState(() => _tab = index),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.circle_outlined),
          selectedIcon: const Icon(Icons.circle),
          label: S.of(context).practiceTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.timeline_outlined),
          selectedIcon: const Icon(Icons.timeline),
          label: S.of(context).journeyTab,
        ),
      ],
    ),
  );
}

class _PracticePage extends StatelessWidget {
  const _PracticePage();

  @override
  Widget build(BuildContext context) => Container(
    color: context.palette.background,
    child: SafeArea(
      child: BlocConsumer<MeditationBloc, MeditationState>(
        listener: (context, state) {
          if (state is MeditationInProgress) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<MeditationBloc>(),
                  child: MeditationPage(session: state.session),
                ),
              ),
            );
          } else if (state is MeditationCompleted) {
            getIt<ReviewService>().onSessionCompleted();
          } else if (state is MeditationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: context.palette.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MeditationLoading) {
            return Center(
              child: CircularProgressIndicator(color: context.palette.primary),
            );
          }
          if (state is! MeditationReady) return const SizedBox.shrink();
          final bloc = context.read<MeditationBloc>();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                    sliver: SliverList.list(
                      children: [
                        Row(
                          children: [
                            Text(
                              'volver',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontFamily: 'Newsreader',
                                    fontSize: 25,
                                    letterSpacing: -1,
                                  ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: S.of(context).settingsTitle,
                              icon: Icon(
                                Icons.tune,
                                color: context.palette.textSecondary,
                              ),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: bloc,
                                    child: const SettingsPage(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text(
                          S.of(context).homeGreeting,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontFamily: 'Newsreader',
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          S.of(context).homeSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        AttentionThread(
                          height: 72,
                          semanticLabel: S.of(context).threadDescription,
                        ),
                        const SizedBox(height: 18),
                        DurationPicker(
                          selectedMinutes: state.durationMinutes,
                          onChanged: (minutes) =>
                              bloc.add(ChangeDurationEvent(minutes)),
                        ),
                        const SizedBox(height: 4),
                        Semantics(
                          label:
                              '${S.of(context).soundSummary}: '
                              '${S.of(context).soundName(state.selectedSound.id)}',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 18,
                                color: context.palette.textMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${S.of(context).soundSummary} · '
                                '${S.of(context).soundName(state.selectedSound.id)}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: MeditationButton(
                            isActive: false,
                            onPressed: () =>
                                bloc.add(const StartMeditationEvent()),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          S.of(context).gentleReturn,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
