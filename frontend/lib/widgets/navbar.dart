import 'package:flutter/material.dart';
import '../screens/journal/journal_options_screen.dart'; // import the new screen

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
            color: theme.shadowColor.withOpacity(0.3),
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
                  // Navigate to the JournalOptionsScreen instead of MoodTrackingScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JournalOptionsScreen(),
                    ),
                  );
                  onTap(1);
                },
              ),
              _buildEmergencyButton(context),
              _buildNavItem(context, 3, Icons.analytics_outlined,
                  Icons.analytics, 'Stats'),
              _buildNavItem(
                  context, 4, Icons.person_outlined, Icons.person, 'Profile'),
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
                : theme.colorScheme.onSurface.withOpacity(0.64),
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
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onEmergencyPress,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.error.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.emergency,
          color: theme.colorScheme.onError,
          size: 32,
        ),
      ),
    );
  }
}
