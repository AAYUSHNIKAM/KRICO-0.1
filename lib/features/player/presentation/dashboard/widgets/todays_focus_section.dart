import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../design_system/colors/app_colors.dart';
import '../../../../../design_system/typography/text_styles.dart';
import '../../../../../design_system/spacing/spacing_scale.dart';
import '../../../../../design_system/radius/radius.dart';
import '../../../../../design_system/responsive/responsive_helpers.dart';
import '../../../../../services/providers.dart';

class TodaysFocusSection extends ConsumerWidget {
  final String playerId;

  const TodaysFocusSection({super.key, required this.playerId});

  int _dayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerAsync = ref.watch(playerProvider(playerId));

    return playerAsync.when(
      data: (player) {
        final sport = player.sports?.isNotEmpty == true ? player.sports!.first : 'your sport';
        return _TodaysFocusContent(sport: sport, dayOfYear: _dayOfYear());
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _TodaysFocusContent extends StatelessWidget {
  final String sport;
  final int dayOfYear;

  const _TodaysFocusContent({required this.sport, required this.dayOfYear});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = context.isDesktop;
    final isTablet = context.isTablet;
    final padH = isDesktop ? SpacingScale.s32 : (isTablet ? SpacingScale.s24 : SpacingScale.s16);
    final secColor = isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    final sportLower = sport.toLowerCase();
    final List<_FocusData> sportOptions;
    if (sportLower.contains('cricket')) {
      sportOptions = [
        _FocusData(
          title: 'Batting Footwork & Balance',
          description: 'Front-foot drive alignment and head position drills.',
          icon: Icons.sports_cricket_rounded,
          gradientColors: [const Color(0xFF0284C7), const Color(0xFF0369A1)],
          tips: '20 shadow drives holding balance at completion for 3 seconds.',
        ),
        _FocusData(
          title: 'Bowling Run-up Cadence',
          description: 'Gather speed and delivery stride consistency.',
          icon: Icons.speed_rounded,
          gradientColors: [const Color(0xFF059669), const Color(0xFF047857)],
          tips: '6 target deliveries focusing on smooth deceleration.',
        ),
      ];
    } else if (sportLower.contains('badminton') || sportLower.contains('tennis')) {
      sportOptions = [
        _FocusData(
          title: 'Split-Step & Court Agility',
          description: 'Pre-impact reaction step and lateral recovery velocity.',
          icon: Icons.sports_tennis_rounded,
          gradientColors: [const Color(0xFF7C3AED), const Color(0xFF6D28D9)],
          tips: '4 sets of 8-corner agility shadow footwork.',
        ),
        _FocusData(
          title: 'Kinetic Whip & Wrist Snap',
          description: 'Pronation mechanics and clean overhead sweet-spot contact.',
          icon: Icons.flash_on_rounded,
          gradientColors: [const Color(0xFFD97706), const Color(0xFFB45309)],
          tips: '15 overhead repetitions focusing on relaxed forearm rotation.',
        ),
      ];
    } else if (sportLower.contains('football') || sportLower.contains('soccer')) {
      sportOptions = [
        _FocusData(
          title: 'First Touch & Directional Control',
          description: 'Cushioning aerial passes and turning into open space.',
          icon: Icons.sports_soccer_rounded,
          gradientColors: [const Color(0xFF2563EB), const Color(0xFF1E40AF)],
          tips: '30 two-touch wall rebounds alternating both feet.',
        ),
      ];
    } else {
      sportOptions = [
        _FocusData(
          title: 'Athletic Conditioning & Core',
          description: 'Explosive acceleration and movement stability.',
          icon: Icons.fitness_center_rounded,
          gradientColors: [const Color(0xFF0D9488), const Color(0xFF0F766E)],
          tips: '3 sets of planks, lunges, and high-knee skips.',
        ),
      ];
    }

    final generalOptions = [
      _FocusData(
        title: 'Active Mobility & Recovery',
        description: 'Post-session foam rolling and dynamic joint mobility.',
        icon: Icons.self_improvement_rounded,
        gradientColors: [const Color(0xFF4F46E5), const Color(0xFF4338CA)],
        tips: '15 min hip and hamstring active stretch routine.',
      ),
      _FocusData(
        title: 'Daily Training Commitment',
        description: 'Lock in your target focus for upcoming sessions.',
        icon: Icons.flag_rounded,
        gradientColors: [const Color(0xFFDC2626), const Color(0xFFB91C1C)],
        tips: 'Review coach notes from your last training debrief.',
      ),
    ];

    final combined = [...sportOptions, ...generalOptions];
    final focus = combined[dayOfYear % combined.length];

    return Padding(
      padding: EdgeInsets.fromLTRB(padH, SpacingScale.s24, padH, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S FOCUS",
            style: AppTextStyles.captionXs.copyWith(
              color: secColor,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: SpacingScale.s12),
          Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.brXl3,
              gradient: LinearGradient(
                colors: focus.gradientColors.map((c) => c.withValues(alpha: 0.9)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: focus.gradientColors.first.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppRadius.brXl3,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Focus: ${focus.title} — ${focus.tips}'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(SpacingScale.s24),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: AppRadius.brXl2,
                        ),
                        child: Icon(focus.icon, size: 26, color: Colors.white),
                      ),
                      const SizedBox(width: SpacingScale.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              focus.title,
                              style: AppTextStyles.title1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: SpacingScale.s4),
                            Text(
                              focus.description,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: SpacingScale.s8),
                            Row(
                              children: [
                                Icon(Icons.lightbulb_outline_rounded, size: 14, color: Colors.white.withValues(alpha: 0.7)),
                                const SizedBox(width: SpacingScale.s6),
                                Expanded(
                                  child: Text(
                                    focus.tips,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: SpacingScale.s12),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.06, end: 0),
        ],
      ),
    );
  }
}

class _FocusData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String tips;

  const _FocusData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.tips,
  });
}
