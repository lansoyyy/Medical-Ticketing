import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text_styles.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback? onTap;
  final int? badgeCount;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.isExpanded = true,
    this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 16 : 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight.withOpacity(0.2) : null,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.accent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.white.withOpacity(0.8),
                    size: 22,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.white.withOpacity(0.8),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
