import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/widgets/page_headers/page_hero.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/radius/radius.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../design_system/utils/extensions.dart';
import '../../../services/providers.dart';

class StudentsTab extends ConsumerStatefulWidget {
  final String coachId;
  const StudentsTab({super.key, required this.coachId});

  @override
  ConsumerState<StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends ConsumerState<StudentsTab> {
  int _selectedSegment = 0; // 0: 1-on-1 Athletes, 1: Academy Batches

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(coachPlayersProvider(widget.coachId));
    final batchesAsync = ref.watch(coachBatchesProvider(widget.coachId));
    final coachAsync = ref.watch(coachProvider(widget.coachId));
    final coach = coachAsync.asData?.value;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final padH = context.width > 1280
        ? SpacingScale.s32
        : context.width > 600
            ? SpacingScale.s24
            : SpacingScale.s16;

    final privateCount = studentsAsync.asData?.value.length ?? 0;
    final batchCount = batchesAsync.asData?.value.docs.length ?? 0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surface : AppColors.lightSurface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: CustomScrollView(
            slivers: [
              const PageHero(
                title: 'Student Roster',
                subtitle: 'Monitor private athletes & academy batch enrollment',
                backgroundColor: AppColors.primary,
              ),
              // Segment Selector Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(padH, SpacingScale.s16, padH, SpacingScale.s12),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131D31) : AppColors.lightSurfaceSecondary,
                      borderRadius: AppRadius.brXl,
                      border: Border.all(
                        color: isDark ? AppColors.border : AppColors.lightBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentButton(
                            title: '1-on-1 Athletes ($privateCount)',
                            icon: Icons.person_rounded,
                            isSelected: _selectedSegment == 0,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedSegment = 0),
                          ),
                        ),
                        Expanded(
                          child: _buildSegmentButton(
                            title: 'Academy Batches ($batchCount)',
                            icon: Icons.groups_rounded,
                            isSelected: _selectedSegment == 1,
                            isDark: isDark,
                            onTap: () => setState(() => _selectedSegment = 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (_selectedSegment == 0)
                _buildPrivateAthletesSliver(studentsAsync, padH, isDark)
              else
                _buildAcademyBatchesSliver(batchesAsync, coach, padH, isDark),

              const SliverToBoxAdapter(child: SizedBox(height: SpacingScale.s40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brLg,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.volt : AppColors.midnightObsidian)
              : Colors.transparent,
          borderRadius: AppRadius.brLg,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? AppColors.volt : Colors.black).withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? (isDark ? Colors.black : Colors.white)
                  : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateAthletesSliver(
    AsyncValue<List<Map<String, dynamic>>> studentsAsync,
    double padH,
    bool isDark,
  ) {
    return studentsAsync.when(
      data: (docs) {
        if (docs.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              padding: const EdgeInsets.all(SpacingScale.s40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.textTertiary : AppColors.lightTextTertiary).withValues(alpha: 0.12),
                        borderRadius: AppRadius.brXl2,
                      ),
                      child: Icon(Icons.people_outline_rounded,
                          size: 32,
                          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                    ),
                    const SizedBox(height: SpacingScale.s16),
                    Text('No private students yet',
                        style: AppTextStyles.title3.copyWith(
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: SpacingScale.s4),
                    Text('Students appear automatically when they book 1-on-1 sessions',
                        style: AppTextStyles.bodySm.copyWith(
                          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        )),
                  ],
                ),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final data = docs[index];
              final name = data['name'] as String? ?? 'Unknown';
              final level = data['level'] as String? ?? 'Beginner';
              final points = (data['points'] as num?)?.toInt() ?? 0;
              final sport = (data['sports'] as List<dynamic>?)?.cast<String>() ?? ['General'];
              final rank = (data['rank'] as num?)?.toInt() ?? 0;
              final playerId = data['playerId'] as String? ?? '';

              return GestureDetector(
                onTap: () => context.push(
                  '/student-progress/$playerId',
                  extra: {'coachId': widget.coachId},
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: padH, vertical: SpacingScale.s6),
                  padding: const EdgeInsets.all(SpacingScale.s16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightCard,
                    borderRadius: AppRadius.brXl3,
                    border: Border.all(
                      color: isDark ? AppColors.border : AppColors.lightBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.push('/profile/$playerId'),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.purple,
                            borderRadius: AppRadius.brLg,
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: SpacingScale.s16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: AppTextStyles.title3.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: SpacingScale.s2),
                            Text('${sport.join(", ")} • $level',
                                style: AppTextStyles.body.copyWith(
                                    color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: SpacingScale.s8, vertical: SpacingScale.s2),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withValues(alpha: 0.12),
                              borderRadius: AppRadius.brLg,
                            ),
                            child: Text('#$rank',
                                style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.purple, fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(height: SpacingScale.s4),
                          Text('$points XP',
                              style: AppTextStyles.bodySm.copyWith(
                                  color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary)),
                        ],
                      ),
                      const SizedBox(width: SpacingScale.s8),
                      Icon(Icons.chevron_right_rounded,
                          size: 20,
                          color: isDark ? AppColors.textTertiary : AppColors.lightTextTertiary),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.05, end: 0);
            },
            childCount: docs.length,
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Unable to load private athletes: $e')),
      ),
    );
  }

  Widget _buildAcademyBatchesSliver(
    AsyncValue<dynamic> batchesAsync,
    dynamic coach,
    double padH,
    bool isDark,
  ) {
    return batchesAsync.when(
      data: (snap) {
        final docs = snap.docs;
        if (docs.isEmpty) {
          final isAffiliated = coach != null && (coach.academyId ?? '').isNotEmpty;
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              padding: const EdgeInsets.all(SpacingScale.s32),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.12),
                        borderRadius: AppRadius.brXl2,
                      ),
                      child: const Icon(Icons.school_rounded, size: 32, color: AppColors.cyan),
                    ),
                    const SizedBox(height: SpacingScale.s16),
                    Text(
                      isAffiliated ? 'No Batches Assigned to You' : 'Not Affiliated with an Academy Yet',
                      style: AppTextStyles.title3.copyWith(
                        color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s6),
                    Text(
                      isAffiliated
                          ? 'Your academy has not yet assigned active batches to your profile. Ask your academy administrator to assign you as the primary coach.'
                          : 'Register or join an academy to monitor structured student batches, attendance, and enrollment status.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm.copyWith(
                        color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: SpacingScale.s20),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.volt : AppColors.midnightObsidian,
                        foregroundColor: isDark ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
                      ),
                      icon: const Icon(Icons.work_outline_rounded, size: 16),
                      label: const Text('Explore Academy Jobs & Offers'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final batchId = doc.id;
              final name = data['name'] as String? ?? 'Training Batch';
              final sport = data['sport'] as String? ?? 'General';
              final schedule = data['schedule'] as String? ?? 'Flexible schedule';
              final capacity = (data['capacity'] as num?)?.toInt() ?? 20;

              return _BatchRosterCard(
                batchId: batchId,
                name: name,
                sport: sport,
                schedule: schedule,
                capacity: capacity,
                padH: padH,
                isDark: isDark,
              );
            },
            childCount: docs.length,
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => SliverFillRemaining(
        child: Center(child: Text('Unable to load academy batches: $e')),
      ),
    );
  }
}

class _BatchRosterCard extends ConsumerStatefulWidget {
  final String batchId;
  final String name;
  final String sport;
  final String schedule;
  final int capacity;
  final double padH;
  final bool isDark;

  const _BatchRosterCard({
    required this.batchId,
    required this.name,
    required this.sport,
    required this.schedule,
    required this.capacity,
    required this.padH,
    required this.isDark,
  });

  @override
  ConsumerState<_BatchRosterCard> createState() => _BatchRosterCardState();
}

class _BatchRosterCardState extends ConsumerState<_BatchRosterCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(batchStudentsProvider(widget.batchId));
    final cardBg = widget.isDark ? AppColors.card : AppColors.lightCard;
    final borderColor = widget.isDark ? AppColors.border : AppColors.lightBorder;
    final textColor = widget.isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
    final subColor = widget.isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.padH, vertical: SpacingScale.s10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.brXl3,
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Batch Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(SpacingScale.s16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.15),
                      borderRadius: AppRadius.brLg,
                    ),
                    child: const Icon(Icons.sports_rounded, color: AppColors.cyan, size: 22),
                  ),
                  const SizedBox(width: SpacingScale.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.sport.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: widget.isDark ? AppColors.volt : AppColors.lightAccentVolt,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.name,
                          style: AppTextStyles.title3.copyWith(
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 12, color: subColor),
                            const SizedBox(width: 4),
                            Text(widget.schedule, style: AppTextStyles.captionXs.copyWith(color: subColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  studentsAsync.when(
                    data: (snap) {
                      final activeCount = snap.docs.where((d) => (d.data()['status'] as String? ?? 'active') == 'active').length;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (activeCount >= widget.capacity ? AppColors.warning : AppColors.emerald).withValues(alpha: 0.12),
                          borderRadius: AppRadius.brSm,
                          border: Border.all(
                            color: (activeCount >= widget.capacity ? AppColors.warning : AppColors.emerald).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '$activeCount / ${widget.capacity} Enrolled',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: activeCount >= widget.capacity ? AppColors.warning : AppColors.emerald,
                          ),
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: subColor,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Divider(height: 1, color: borderColor),
            studentsAsync.when(
              data: (snap) {
                final studentDocs = snap.docs;
                if (studentDocs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(SpacingScale.s20),
                    child: Center(
                      child: Text(
                        'No students enrolled in this batch yet.',
                        style: AppTextStyles.bodySm.copyWith(color: subColor),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: studentDocs.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: borderColor.withValues(alpha: 0.5)),
                  itemBuilder: (context, idx) {
                    final sDoc = studentDocs[idx];
                    final sData = sDoc.data();
                    final sId = sDoc.id;
                    final sName = sData['name'] as String? ?? 'Student';
                    final sPhone = sData['phone'] as String? ?? '';
                    final status = sData['status'] as String? ?? 'active';
                    final isEnrolled = status == 'active';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: SpacingScale.s16, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isEnrolled
                                  ? AppColors.emerald.withValues(alpha: 0.15)
                                  : Colors.redAccent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                sName.isNotEmpty ? sName[0].toUpperCase() : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: isEnrolled ? AppColors.emerald : Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: SpacingScale.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                                if (sPhone.isNotEmpty)
                                  Text(
                                    sPhone,
                                    style: TextStyle(fontSize: 11, color: subColor),
                                  ),
                              ],
                            ),
                          ),
                          // Enrolled / Exited Status Chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isEnrolled ? AppColors.emerald : Colors.redAccent).withValues(alpha: 0.12),
                              borderRadius: AppRadius.brSm,
                              border: Border.all(
                                color: (isEnrolled ? AppColors.emerald : Colors.redAccent).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isEnrolled ? AppColors.emerald : Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isEnrolled ? 'ENROLLED' : 'EXITED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: isEnrolled ? AppColors.emerald : Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Toggle Status Menu Button
                          PopupMenuButton<String>(
                            tooltip: 'Update Student Status',
                            icon: Icon(Icons.more_vert_rounded, size: 18, color: subColor),
                            onSelected: (action) async {
                              final newStatus = action == 'exit' ? 'exited' : 'active';
                              try {
                                await ref.read(academyServiceProvider).updateBatchStudentStatus(
                                  batchId: widget.batchId,
                                  studentId: sId,
                                  newStatus: newStatus,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(action == 'exit'
                                          ? '$sName marked as Exited from batch'
                                          : '$sName re-enrolled into batch'),
                                      backgroundColor: action == 'exit' ? AppColors.warning : AppColors.success,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.danger),
                                  );
                                }
                              }
                            },
                            itemBuilder: (ctx) => [
                              if (isEnrolled)
                                const PopupMenuItem(
                                  value: 'exit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_remove_rounded, color: Colors.redAccent, size: 16),
                                      SizedBox(width: 8),
                                      Text('Mark as Exited', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                )
                              else
                                const PopupMenuItem(
                                  value: 'enroll',
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_add_rounded, color: AppColors.emerald, size: 16),
                                      SizedBox(width: 8),
                                      Text('Re-Enroll Student', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(SpacingScale.s16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(SpacingScale.s16),
                child: Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
