import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Responder Incident Detail Screen
/// Shown when tapping an incident card in the history screen.
class ResponderIncidentDetail extends StatelessWidget {
  final String title;
  final String category;
  final String address;
  final String time;
  final String status;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const ResponderIncidentDetail({
    super.key,
    required this.title,
    required this.category,
    required this.address,
    required this.time,
    required this.status,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            // ── Topbar ───────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: cs.onSurface.withOpacity(0.7)),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'INCIDENT DETAILS',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  // Balance spacer — same width as back button
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Identity Card
                    _IdentityCard(
                      title: title,
                      category: category,
                      address: address,
                      time: time,
                      status: status,
                      icon: icon,
                      iconBg: iconBg,
                      iconColor: iconColor,
                      theme: theme,
                      cs: cs,
                    ),
                    const SizedBox(height: 16),

                    // Response Stats Row
                    _ResponseStatsRow(theme: theme, cs: cs),
                    const SizedBox(height: 20),

                    // Section header
                    _SectionLabel('RESPONSE TIMELINE', theme: theme, cs: cs),
                    const SizedBox(height: 12),
                    _TimelineSection(theme: theme, cs: cs),
                    const SizedBox(height: 20),

                    // Patient info
                    _SectionLabel('PATIENT DETAILS', theme: theme, cs: cs),
                    const SizedBox(height: 12),
                    _PatientCard(theme: theme, cs: cs),
                    const SizedBox(height: 20),

                    // Scene evidence
                    _SectionLabel('SCENE EVIDENCE', theme: theme, cs: cs),
                    const SizedBox(height: 12),
                    _EvidenceGrid(theme: theme, cs: cs),
                    const SizedBox(height: 20),

                    // Responder Notes
                    _SectionLabel('RESPONDER NOTES', theme: theme, cs: cs),
                    const SizedBox(height: 12),
                    _NotesCard(theme: theme, cs: cs),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final ColorScheme cs;
  const _SectionLabel(this.label, {required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: cs.onSurface.withOpacity(0.45),
        fontSize: 11,
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final String title, category, address, time, status;
  final IconData icon;
  final Color iconBg, iconColor;
  final ThemeData theme;
  final ColorScheme cs;

  const _IdentityCard({
    required this.title,
    required this.category,
    required this.address,
    required this.time,
    required this.status,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: icon + category + status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.4),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),

          // Location
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 14, color: cs.onSurface.withOpacity(0.4)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 14, color: cs.onSurface.withOpacity(0.4)),
              const SizedBox(width: 6),
              Text(
                time,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ID #RA-7821',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.45),
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResponseStatsRow extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  const _ResponseStatsRow({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat('RESPONSE TIME', '3m 42s', Icons.bolt_rounded,
          const Color(0xFFFF6B35)),
      _Stat('ON-SCENE', '28m 15s', Icons.location_on_rounded,
          const Color(0xFF004F9F)),
      _Stat(
          'OUTCOME', 'Stable', Icons.favorite_rounded, const Color(0xFF2E7D32)),
    ];

    return Row(
      children: stats.map((s) {
        final isLast = s == stats.last;
        return Expanded(
          child: Container(
            margin: isLast ? EdgeInsets.zero : const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(s.icon, size: 16, color: s.color),
                const SizedBox(height: 6),
                Text(
                  s.value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.headingColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Stat {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat(this.label, this.value, this.icon, this.color);
}

class _TimelineSection extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  const _TimelineSection({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep('Dispatch Received', '14:18', true),
      _TimelineStep('En Route', '14:20', true),
      _TimelineStep('On Scene Arrival', '14:22', true),
      _TimelineStep('Patient Stabilised', '14:38', true),
      _TimelineStep('Incident Resolved', '14:50', true),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline spine
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: step.done
                          ? AppTheme.primary
                          : cs.onSurface.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.done
                            ? AppTheme.primary.withOpacity(0.3)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 1.5,
                      height: 36,
                      color: AppTheme.primary.withOpacity(0.15),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.headingColor,
                        ),
                      ),
                      Text(
                        step.time,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.45),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TimelineStep {
  final String label, time;
  final bool done;
  const _TimelineStep(this.label, this.time, this.done);
}

class _PatientCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  const _PatientCard({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    final details = [
      ('SEX / AGE', 'Male, ~65 yrs'),
      ('CONDITION', 'Cardiac Arrest'),
      ('INITIAL STATE', 'Unresponsive, no pulse'),
      ('TREATMENT', 'CPR + AED applied'),
      ('TRANSFERRED TO', 'Metro General Hospital'),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(details.length, (i) {
          final (label, value) = details[i];
          final isLast = i == details.length - 1;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.4),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.headingColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 10),
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _EvidenceGrid extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  const _EvidenceGrid({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF1B2838),
      const Color(0xFF263238),
      const Color(0xFF37474F),
    ];

    return Row(
      children: List.generate(3, (i) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
            height: 90,
            decoration: BoxDecoration(
              color: colors[i],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image_rounded,
                    color: Colors.white54, size: 22),
                const SizedBox(height: 4),
                Text(
                  'Photo ${i + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _NotesCard extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme cs;
  const _NotesCard({required this.theme, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Unit 402 — Responder Notes',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.headingColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Patient found unresponsive on platform with bystander already performing CPR. AED applied, two shocks administered. Pulse restored at 14:36. Patient conscious but disoriented upon transfer to EMS team. Scene cleared at 14:50.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.65),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
