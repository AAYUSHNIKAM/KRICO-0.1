import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sports_app/design_system/colors/app_colors.dart';
import 'package:sports_app/design_system/radius/radius.dart';
import 'package:sports_app/design_system/spacing/spacing_scale.dart';
import 'package:sports_app/design_system/typography/text_styles.dart';
import 'package:sports_app/design_system/layouts/premium_shell.dart';
import 'package:sports_app/models/coach_model.dart';
import 'package:sports_app/models/certificate_model.dart';
import 'package:sports_app/models/player_model.dart';
import 'package:sports_app/models/user_model.dart';
import 'package:sports_app/services/providers.dart';
import 'package:sports_app/features/home/presentation/workspace_destinations.dart';
import 'package:sports_app/core/gamification/krico_xp_system.dart';
import 'hud_widgets/live_stadium_ticket_hero.dart';

class PlayerHomeView extends ConsumerWidget {
  const PlayerHomeView({
    super.key,
    required this.user,
    required this.destinations,
  });

  final UserModel user;
  final List<WorkspaceDestination> destinations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionsAsync = ref.watch(playerSessionsProvider(user.uid));
    final coachesAsync = ref.watch(coachesStreamProvider);
    final playerAsync = ref.watch(playerProvider(user.uid));

    final textColor = isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Athlete Command Header
                _buildAthleteHeader(context, isDark, textColor, subColor, playerAsync.asData?.value),
                const SizedBox(height: SpacingScale.s24),

                // 1. Live Coaching Session Ticket & Gate Pass Hero
                sessionsAsync.when(
                  data: (snap) {
                    final now = DateTime.now();
                    final upcomingSessions = snap.docs.where((d) {
                      final raw = d.data()['dateTime'];
                      final DateTime? time = raw is Timestamp
                          ? raw.toDate()
                          : (raw is DateTime ? raw : null);
                      final status = d.data()['status'] as String? ?? '';
                      return time != null && time.isAfter(now) && status != 'cancelled';
                    }).toList();

                    final nextSession = upcomingSessions.isNotEmpty ? upcomingSessions.first.data() : null;
                    return LiveStadiumTicketHero(
                      sessionDoc: nextSession,
                      userName: user.name,
                    );
                  },
                  loading: () => SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator(color: isDark ? AppColors.volt : AppColors.lightAccentVolt)),
                  ),
                  error: (_, _) => LiveStadiumTicketHero(
                    sessionDoc: null,
                    userName: user.name,
                  ),
                ),
                const SizedBox(height: SpacingScale.s28),

                // 2. Verified Athlete Performance & Readiness Card
                _buildPerformanceOverviewCard(context, isDark, textColor, subColor, playerAsync.asData?.value),
                const SizedBox(height: SpacingScale.s28),

                // 3. Official Verified Certification & Milestone Card
                _buildMilestonesCard(context, isDark, textColor, subColor, playerAsync.asData?.value),
                const SizedBox(height: SpacingScale.s32),

                // 4. Interactive Sport Realm Horizon Bar
                _buildSportCategoryPills(context, isDark, textColor, subColor),
                const SizedBox(height: SpacingScale.s28),

                // 5. Featured & Verified Specialists Carousel
                _buildFeaturedCoaches(context, isDark, textColor, subColor, coachesAsync),
                const SizedBox(height: SpacingScale.s32),

                // 6. Recent Training Activity / Completed Sessions
                _buildRecentSessionsLedger(context, isDark, textColor, subColor, sessionsAsync),
                const SizedBox(height: SpacingScale.s40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteHeader(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subColor,
    PlayerModel? player,
  ) {
    final readiness = player?.readinessStatus ?? 'Fundamentals';
    final readinessColor = switch (readiness) {
      'Elite Roster' => AppColors.gold,
      'Tournament Ready' => AppColors.emerald,
      'Sparring Ready' => AppColors.cyan,
      _ => const Color(0xFF94A3B8),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AppColors.volt : AppColors.lightAccentVolt, width: 2),
                color: isDark ? AppColors.surfaceSecondary : AppColors.lightSurfaceSecondary,
              ),
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.volt : AppColors.lightAccentVolt,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SpacingScale.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Welcome, ${user.name}',
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: readinessColor.withValues(alpha: 0.15),
                          borderRadius: AppRadius.brFull,
                          border: Border.all(color: readinessColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          readiness.toUpperCase(),
                          style: TextStyle(
                            color: readinessColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Coach-verified athletic training hub • Pune Grassroots Ecosystem',
                    style: AppTextStyles.caption.copyWith(color: subColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingScale.s16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => WorkspaceNavigation.go(context, 1),
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? AppColors.heroDarkCta : AppColors.heroLightCta,
              foregroundColor: isDark ? AppColors.midnightObsidian : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
            ),
            icon: Icon(
              destinations.length > 1 ? destinations[1].icon : Icons.person_search_rounded,
              size: 16,
            ),
            label: Text(
              destinations.length > 1 ? destinations[1].label : 'Find a coach',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceOverviewCard(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subColor,
    PlayerModel? player,
  ) {
    final points = player?.points ?? 0;
    final level = KricoXpSystem.getLevelInfo(points);
    final progress = level.progressPercent;
    final streak = player?.consistencyStreak ?? 0;
    final totalDrills = player?.totalDrills ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(SpacingScale.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.15),
                  borderRadius: AppRadius.brMd,
                ),
                child: const Icon(Icons.speed_rounded, color: AppColors.cyan, size: 20),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VERIFIED ATHLETIC TELEMETRY',
                      style: AppTextStyles.captionXs.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cyan,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Performance & Growth Status',
                      style: AppTextStyles.title2.copyWith(
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => WorkspaceNavigation.go(context, 1),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.volt : AppColors.lightAccentVolt,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                icon: const Icon(Icons.analytics_rounded, size: 16),
                label: const Text('View Reports', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s20),
          Row(
            children: [
              Expanded(
                child: _statPill(
                  label: 'TOTAL XP',
                  value: '$points XP',
                  sub: '${(progress * 100).toInt()}% to Next',
                  color: AppColors.volt,
                  icon: Icons.bolt_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statPill(
                  label: 'LEVEL',
                  value: 'Lv. ${level.level}',
                  sub: level.title,
                  color: AppColors.purple,
                  icon: Icons.military_tech_rounded,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statPill(
                  label: 'ACTIVE STREAK',
                  value: '$streak Days',
                  sub: 'Training Rhythm',
                  color: AppColors.emerald,
                  icon: Icons.local_fire_department_rounded,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s16),
          ClipRRect(
            borderRadius: AppRadius.brFull,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: isDark ? AppColors.border : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppColors.volt : AppColors.lightAccentVolt),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Current: ${level.title}',
                  style: AppTextStyles.captionXs.copyWith(color: subColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$totalDrills Verified Drills Logged',
                  style: AppTextStyles.captionXs.copyWith(color: subColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    final effectiveColor = isDark
        ? color
        : (color == AppColors.volt ? AppColors.lightAccentVolt : color);
    final isVoltStat = color == AppColors.volt;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        borderRadius: AppRadius.brLg,
        border: Border.all(
          color: isDark
              ? AppColors.border
              : (isVoltStat ? AppColors.lightBorder : effectiveColor.withValues(alpha: 0.35)),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: isDark
                      ? color.withValues(alpha: 0.15)
                      : (isVoltStat
                          ? AppColors.lightVoltBadge.withValues(alpha: 0.35)
                          : effectiveColor.withValues(alpha: 0.12)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 13,
                  color: isDark
                      ? color
                      : (isVoltStat ? AppColors.lightTextPrimary : effectiveColor),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? color
                        : (isVoltStat ? AppColors.lightAccentVolt : effectiveColor),
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesCard(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subColor,
    PlayerModel? player,
  ) {
    final points = player?.points ?? 0;
    final currentTier = CertificateRegistry.getTierByXp(points);
    final nextTier = CertificateRegistry.getNextTier(points);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: (currentTier?.primaryColor ?? AppColors.gold).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (currentTier?.primaryColor ?? AppColors.gold).withValues(alpha: isDark ? 0.08 : 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(SpacingScale.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (currentTier?.primaryColor ?? AppColors.gold).withValues(alpha: 0.15),
                  borderRadius: AppRadius.brMd,
                ),
                child: Icon(Icons.workspace_premium_rounded,
                    color: currentTier?.primaryColor ?? AppColors.gold, size: 20),
              ),
              const SizedBox(width: SpacingScale.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '15-TIER ATHLETIC CERTIFICATION',
                      style: AppTextStyles.captionXs.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w800,
                        color: currentTier?.primaryColor ?? AppColors.gold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currentTier?.title ?? 'Tier 1: Foundational Athlete',
                      style: AppTextStyles.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      nextTier != null
                          ? 'Next Milestone: ${nextTier.title} (${nextTier.requiredXp - points} XP away)'
                          : 'Maximum Prestige Laureate Reached',
                      style: AppTextStyles.captionXs.copyWith(color: subColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => context.push('/player-certificates/${user.uid}'),
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? AppColors.heroDarkCta : AppColors.heroLightCta,
                  foregroundColor: isDark ? AppColors.midnightObsidian : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
                ),
                icon: const Icon(Icons.download_rounded, size: 14),
                label: const Text('Certificates', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessionsLedger(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subColor,
    AsyncValue<QuerySnapshot<Map<String, dynamic>>> sessionsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Training Session Ledger',
                    style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Verified coaching sessions & attendance history',
                    style: AppTextStyles.caption.copyWith(color: subColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => context.push('/bookings'),
              icon: const Icon(Icons.calendar_month_outlined, size: 16),
              label: const Text('All Sessions'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        sessionsAsync.when(
          data: (snap) {
            final completedSessions = snap.docs.where((d) {
              final status = d.data()['status'] as String? ?? '';
              return status == 'completed' || status == 'confirmed';
            }).take(3).toList();

            if (completedSessions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(SpacingScale.s24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card : AppColors.lightCard,
                  borderRadius: AppRadius.brXl3,
                  border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                ),
                alignment: Alignment.center,
                child: Text(
                  'No completed sessions logged yet. Your coaching attendance ledger will appear here.',
                  style: AppTextStyles.bodySm.copyWith(color: subColor),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: completedSessions.map((doc) {
                final data = doc.data();
                final coach = data['coachName'] as String? ?? 'Coach';
                final sport = data['sport'] as String? ?? 'Training';
                final rawDate = data['dateTime'];
                final DateTime date = rawDate is Timestamp
                    ? rawDate.toDate()
                    : (rawDate is DateTime ? rawDate : DateTime.now());

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightCard,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$sport with $coach',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('EEEE, MMM d, yyyy').format(date),
                              style: TextStyle(color: subColor, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.emerald.withValues(alpha: 0.12),
                          borderRadius: AppRadius.brSm,
                        ),
                        child: const Text(
                          'ATTENDED',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSportCategoryPills(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subColor,
  ) {
    final sports = [
      (title: 'Badminton', icon: Icons.sports_tennis_rounded, count: '14 Specialists', color: AppColors.cyan),
      (title: 'Cricket', icon: Icons.sports_cricket_rounded, count: '28 Coaches', color: AppColors.orange),
      (title: 'Football', icon: Icons.sports_soccer_rounded, count: '19 Coaches', color: AppColors.emerald),
      (title: 'Swimming', icon: Icons.pool_rounded, count: '8 Certified', color: AppColors.cyan),
      (title: 'Tennis', icon: Icons.sports_baseball_rounded, count: '11 Coaches', color: AppColors.gold),
      (title: 'Athletics', icon: Icons.directions_run_rounded, count: '7 Trainers', color: AppColors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Disciplines',
          style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sports.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final s = sports[i];
              final accent = isDark
                  ? (s.color == AppColors.volt ? AppColors.volt : s.color)
                  : (s.color == AppColors.volt ? AppColors.lightAccentVolt : s.color);

              return InkWell(
                onTap: () => context.push('/coach-discovery'),
                borderRadius: AppRadius.brLg,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : Colors.white,
                    borderRadius: AppRadius.brLg,
                    border: Border.all(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.16 : 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(s.icon, color: accent, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: textColor,
                            ),
                          ),
                          Text(s.count, style: TextStyle(color: subColor, fontSize: 9.5)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCoaches(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color subColor,
    AsyncValue<List<CoachModel>> coachesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Elite Specialists',
                    style: AppTextStyles.title2.copyWith(color: textColor, fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Verified NIS & International certified specialists',
                    style: AppTextStyles.caption.copyWith(color: subColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => context.push('/coach-discovery'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 16),
              label: const Text('Explore'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        coachesAsync.when(
          data: (coaches) {
            if (coaches.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(SpacingScale.s20),
                alignment: Alignment.center,
                child: Text('No coaches available yet', style: AppTextStyles.bodySm),
              );
            }

            final featured = coaches.take(6).toList();
            return SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featured.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final coach = featured[i];
                  return _coachCard(context, coach, isDark, textColor, subColor);
                },
              ),
            );
          },
          loading: () => SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator(color: isDark ? AppColors.volt : AppColors.lightAccentVolt)),
          ),
          error: (e, _) => Text('Error loading coaches: $e'),
        ),
      ],
    );
  }

  Widget _coachCard(
    BuildContext context,
    CoachModel coach,
    bool isDark,
    Color textColor,
    Color subColor,
  ) {
    final sport = coach.specialization ?? 'Sports Coach';

    return Container(
      width: 230,
      padding: const EdgeInsets.all(SpacingScale.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightCard,
        borderRadius: AppRadius.brXl3,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? null
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF20251D), Color(0xFF353C30)],
                        ),
                  color: isDark ? AppColors.volt.withValues(alpha: 0.15) : null,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.volt.withValues(alpha: 0.4) : AppColors.lightVoltBadge,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    coach.name.isNotEmpty ? coach.name[0].toUpperCase() : 'C',
                    style: TextStyle(
                      color: isDark ? AppColors.volt : AppColors.lightVoltBadge,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SpacingScale.s10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name,
                      style: AppTextStyles.title3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      sport,
                      style: AppTextStyles.captionXs.copyWith(color: subColor),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s12),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                coach.rating.toStringAsFixed(1),
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Text(
                '₹${coach.hourlyRate.toInt()}/hr',
                style: AppTextStyles.title3.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.emerald,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingScale.s6),
          Text(
            coach.bio?.isNotEmpty == true
                ? coach.bio!
                : 'Specialized 1-on-1 private coaching for athletic mastery.',
            style: AppTextStyles.caption.copyWith(color: subColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isDark ? AppColors.surfaceElevated : AppColors.heroLightCta,
                foregroundColor: isDark ? Colors.white : AppColors.heroLightCtaText,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.brMd),
              ),
              onPressed: () => context.push('/coach/${coach.coachId}'),
              child: const Text('Book Session', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
