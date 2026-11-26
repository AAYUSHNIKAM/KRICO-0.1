import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/colors/app_colors.dart';
import '../../../design_system/typography/text_styles.dart';
import '../../../design_system/spacing/spacing_scale.dart';
import '../../../models/coach_model.dart';
import '../../../services/providers.dart';

class CoachAcademyJobsScreen extends ConsumerWidget {
  final String coachId;
  const CoachAcademyJobsScreen({super.key, required this.coachId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coachAsync = ref.watch(coachProvider(coachId));
    final coach = coachAsync.asData?.value;
    final jobsAsync = ref.watch(coachJobsProvider);
    final applicationsAsync = ref.watch(coachApplicationsProvider(coachId));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090B10) : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _CoachJobsHeroHeader(
              jobsAsync: jobsAsync,
              applicationsAsync: applicationsAsync,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                jobsAsync.when(
                  data: (snapshot) {
                    final docs = snapshot.docs;
                    if (docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(SpacingScale.s40),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF121622) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.work_off_rounded,
                                  size: 32, color: Color(0xFF00E5FF)),
                            ),
                            const SizedBox(height: SpacingScale.s16),
                            Text('No Coaching Vacancies Posted',
                                style: AppTextStyles.title3.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w700,
                                )),
                            const SizedBox(height: SpacingScale.s4),
                            Text('Check back later for new academy recruitment listings',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: isDark ? Colors.white60 : Colors.black54,
                                )),
                          ],
                        ),
                      );
                    }
                    final appliedJobs = <String>{};
                    final jobStatuses = <String, String>{};
                    final applicationsData = applicationsAsync.asData?.value;
                    if (applicationsData != null) {
                      for (final app in applicationsData.docs) {
                        final appData = app.data();
                        final jobId = appData['jobId'] as String? ?? '';
                        appliedJobs.add(jobId);
                        final status = appData['status'] as String?;
                        if (status != null) jobStatuses[jobId] = status;
                      }
                    }
                    return Column(
                      children: docs.asMap().entries.map((entry) {
                        final index = entry.key;
                        final doc = entry.value;
                        final d = doc.data();
                        final jobId = doc.id;
                        final hasApplied = appliedJobs.contains(jobId);
                        final appStatus = jobStatuses[jobId];
                        return _buildJobCard(
                          context,
                          ref,
                          coach,
                          doc.id,
                          d,
                          hasApplied,
                          appStatus,
                          isDark,
                        )
                            .animate()
                            .fadeIn(delay: (index * 50).ms, duration: 320.ms)
                            .slideY(begin: 0.04, end: 0);
                      }).toList(),
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(SpacingScale.s40),
                      child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                    ),
                  ),
                  error: (e, _) {
                    debugPrint('Coach jobs error: $e');
                    return Container(
                      padding: const EdgeInsets.all(SpacingScale.s40),
                      child: Text('Unable to load coaching vacancies right now.',
                          style: AppTextStyles.body.copyWith(color: AppColors.danger)),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    WidgetRef ref,
    CoachModel? coach,
    String jobId,
    Map<String, dynamic> d, [
    bool hasApplied = false,
    String? appStatus,
    bool isDark = true,
  ]) {
    final title = d['title'] as String? ?? 'Coaching Position';
    final sport = d['sport'] as String? ?? 'General';
    final location = d['location'] as String? ?? 'Remote';
    final salary = d['salary'] as String? ?? 'Negotiable';
    final experience = d['experience'] as String? ?? 'Fresher';
    final description = d['description'] as String? ?? '';
    final perks = d['perks'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121622) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasApplied
              ? const Color(0xFF00E5FF).withValues(alpha: 0.4)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
                ),
                child: const Icon(Icons.sports_rounded, color: Color(0xFF00E5FF), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$sport \u2022 $location',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFF00).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCCFF00).withValues(alpha: 0.3)),
                ),
                child: Text(
                  salary,
                  style: const TextStyle(
                    color: Color(0xFFCCFF00),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildJobTag(Icons.work_history_rounded, experience, const Color(0xFF00E5FF)),
              if (perks.isNotEmpty)
                _buildJobTag(Icons.card_giftcard_rounded, perks, const Color(0xFFFFB300)),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 13,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 14),
          hasApplied
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _statusColor(appStatus).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _statusColor(appStatus).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_statusIcon(appStatus), size: 16, color: _statusColor(appStatus)),
                      const SizedBox(width: 8),
                      Text(
                        appStatus != null ? _capitalize(appStatus).toUpperCase() : 'APPLICATION SUBMITTED',
                        style: TextStyle(
                          color: _statusColor(appStatus),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildApplyButton(
                  context,
                  onPressed: coach != null
                      ? () => _applyForJob(context, ref, coach, jobId, title, d)
                      : null,
                ),
        ],
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'applied':
        return const Color(0xFF00E5FF);
      case 'under_review':
        return const Color(0xFFFFB300);
      case 'interview_scheduled':
        return const Color(0xFFCCFF00);
      case 'accepted':
        return const Color(0xFFCCFF00);
      case 'rejected':
        return AppColors.danger;
      default:
        return Colors.white60;
    }
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'applied':
        return Icons.send_rounded;
      case 'under_review':
        return Icons.visibility_rounded;
      case 'interview_scheduled':
        return Icons.event_available_rounded;
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_empty_rounded;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s.split('_').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');
  }

  Widget _buildApplyButton(BuildContext context, {VoidCallback? onPressed}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: onPressed != null
                  ? [const Color(0xFF00E5FF), const Color(0xFF0088FF)]
                  : [Colors.grey.shade700, Colors.grey.shade800],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (onPressed != null)
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_rounded, size: 16, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Send KRICO Mail & Apply',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  void _applyForJob(
    BuildContext context,
    WidgetRef ref,
    CoachModel coach,
    String jobId,
    String title,
    Map<String, dynamic> jobData,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final academyId = jobData['academyId'] as String? ?? '';
    final sport = jobData['sport'] as String? ?? (coach.sports?.firstOrNull ?? 'General');
    final salary = jobData['salary'] as String? ?? 'Negotiable';

    final subjectCtrl = TextEditingController(text: 'Application for $title');
    final phoneCtrl = TextEditingController(text: coach.phone);
    final expCtrl = TextEditingController(text: '${coach.experience} Years');
    final compCtrl = TextEditingController(text: salary);
    final pitchCtrl = TextEditingController(
      text: coach.bio?.isNotEmpty == true
          ? 'Dear Academy Director,\n\nI am writing to express my strong interest in the $title position at your academy.\n\n${coach.bio}\n\nI look forward to discussing how my experience can elevate your training programs.'
          : 'Dear Academy Director,\n\nI am applying for the $title position. With ${coach.experience} years of coaching experience in $sport, I specialize in athlete development and look forward to contributing to your academy.',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: isDark ? const Color(0xFF141926) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.mark_email_read_rounded, color: Color(0xFF00E5FF), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'KRICO MAIL • COACH → ACADEMY',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                        color: Color(0xFF00E5FF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Job Application & Pitch',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 20, color: isDark ? Colors.white54 : Colors.black54),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Applying for: $title',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.volt : AppColors.lightAccentVolt,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMailField('Subject', subjectCtrl, isDark, maxLines: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildMailField('Experience', expCtrl, isDark)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildMailField('Phone', phoneCtrl, isDark)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildMailField('Expected Compensation', compCtrl, isDark),
                    const SizedBox(height: 10),
                    _buildMailField(
                      'Cover Pitch & Coaching Philosophy',
                      pitchCtrl,
                      isDark,
                      maxLines: 4,
                      hint: 'Describe your training philosophy, past tournament achievements, and availability...',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isDark ? Colors.white70 : Colors.black87,
                              side: BorderSide(
                                color: isDark ? Colors.white24 : Colors.black26,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00E5FF),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              final pitch = pitchCtrl.text.trim();
                              if (pitch.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please include a brief pitch note.')),
                                );
                                return;
                              }
                              await ref.read(academyServiceProvider).sendJobOpeningRequest(
                                jobId: jobId,
                                academyId: academyId,
                                coachId: coach.coachId,
                                coachName: coach.name,
                                coachEmail: coach.email,
                                coachPhone: phoneCtrl.text.trim(),
                                sport: sport,
                                experienceYears: expCtrl.text.trim(),
                                subject: subjectCtrl.text.trim(),
                                coverPitch: pitch,
                                expectedCompensation: compCtrl.text.trim(),
                              );
                              if (context.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('KRICO Mail sent to academy for "$title"!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('Send KRICO Mail', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMailField(
    String label,
    TextEditingController controller,
    bool isDark, {
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            isDense: true,
            filled: true,
            fillColor: isDark ? const Color(0xFF0F1420) : const Color(0xFFF1F3F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

class _CoachJobsHeroHeader extends StatelessWidget {
  final AsyncValue<dynamic> jobsAsync;
  final AsyncValue<dynamic> applicationsAsync;

  const _CoachJobsHeroHeader({
    required this.jobsAsync,
    required this.applicationsAsync,
  });

  @override
  Widget build(BuildContext context) {
    final jobsCount = jobsAsync.asData?.value?.docs?.length ?? 0;
    final appliedCount = applicationsAsync.asData?.value?.docs?.length ?? 0;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: const Color(0xFF090B10),
        image: const DecorationImage(
          image: AssetImage('assets/backgrounds/stadium_floodlights.jpg'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.5),
              const Color(0xFF090B10).withValues(alpha: 0.88),
              const Color(0xFF090B10),
            ],
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E5FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'ACADEMY RECRUITMENT MARKET',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Text(
                    'VERIFIED VACANCIES',
                    style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Academy Coaching Jobs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Explore open coaching contracts and submit applications to elite sports academies',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _buildStatBadge('OPEN POSITIONS', '$jobsCount', const Color(0xFF00E5FF)),
                _buildStatBadge('YOUR APPLICATIONS', '$appliedCount', const Color(0xFFCCFF00)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
