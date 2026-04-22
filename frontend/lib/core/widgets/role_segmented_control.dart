import 'package:flutter/material.dart';
import '../../features/auth/domain/auth_enums.dart';

/// Custom segmented control for role selection.
/// Matches the design: Citizen | Responder | Admin
/// Uses surfaceContainerLow for unselected, primary for selected.
/// No hard borders — "No-Line" rule.
class RoleSegmentedControl extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;

  const RoleSegmentedControl({
    Key? key,
    required this.selectedRole,
    required this.onRoleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: UserRole.values.map((role) {
          final isSelected = role == selectedRole;
          return Expanded(
            child: GestureDetector(
              onTap: () => onRoleChanged(role),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? cs.surfaceContainerLowest : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: cs.primary.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  role.label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? cs.primary : cs.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
