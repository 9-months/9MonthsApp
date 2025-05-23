import 'package:flutter/material.dart';
import 'emergency_btn.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Function() onEmergencyPress;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onEmergencyPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                  context, 0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(
                  context,
                  1,
                  Icons.book_outlined,
                  Icons.book,
                  'Journal',
                  onPressed: () {
                    Navigator.pushNamed(context, '/journal');
                    onTap(1);
                  },
                ),
              _buildEmergencyButton(context),
              _buildNavItem(
                context,
                3,
                Icons.article_outlined,
                Icons.article,
                'News',
                onPressed: () {
                  Navigator.pushNamed(context, '/news');
                  onTap(3);
                },
              ),
              _buildNavItem(
                context,
                4,
                Icons.person_outlined,
                Icons.person,
                'Profile',
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                  onTap(4);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData outlinedIcon,
      IconData filledIcon, String label,
      {VoidCallback? onPressed}) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onPressed ?? () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(
                    alpha: 0.64,
                  ),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.64),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: EmergencyButton(
        icon: Icons.call,
        size: 32,
        color: Colors.white,
      ),
    );
  }
}
