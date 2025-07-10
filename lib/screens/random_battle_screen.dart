import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'team_selection_screen.dart';

class RandomBattleScreen extends StatelessWidget {
  const RandomBattleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Random Battle'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'RANDOM BATTLE',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Face randomly generated opponents',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.shuffle,
                    color: AppColors.secondary,
                    size: 48,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Battle options
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                childAspectRatio: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildBattleOption(
                    context,
                    title: 'Quick Battle',
                    subtitle: 'Fast-paced combat',
                    description:
                        'Jump straight into battle with balanced opponents',
                    icon: Icons.flash_on,
                    color: AppColors.green,
                    onTap: () => _startRandomBattle(context),
                  ),
                  _buildBattleOption(
                    context,
                    title: 'Ranked Battle',
                    subtitle: 'Competitive match',
                    description: 'Face opponents based on your team strength',
                    icon: Icons.emoji_events,
                    color: AppColors.primary,
                    onTap: () => _startRankedBattle(context),
                  ),
                  _buildBattleOption(
                    context,
                    title: 'Survival Mode',
                    subtitle: 'Endless waves',
                    description: 'How many enemies can you defeat in a row?',
                    icon: Icons.timer,
                    color: Colors.orange,
                    onTap: () => _startSurvivalMode(context),
                  ),
                ],
              ),
            ),

            // Info section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Battle Information',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('• Enemies are balanced to your team power'),
                  _buildInfoRow('• Win battles to earn coins and experience'),
                  _buildInfoRow('• Higher difficulty = better rewards'),
                  _buildInfoRow('• Use strategy and special abilities wisely'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattleOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ),
    );
  }

  void _startRandomBattle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TeamSelectionScreen(isCampaign: false),
      ),
    );
  }

  void _startRankedBattle(BuildContext context) {
    // Mostrar dialog de "Coming Soon" por enquanto
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Ranked Battle',
          style: TextStyle(color: AppColors.primary),
        ),
        content: const Text(
          'Ranked battles will be available in a future update!\n\nFor now, enjoy Quick Battles and Campaign mode.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _startSurvivalMode(BuildContext context) {
    // Mostrar dialog de "Coming Soon" por enquanto
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Survival Mode',
          style: TextStyle(color: AppColors.primary),
        ),
        content: const Text(
          'Survival mode will be available in a future update!\n\nPrepare yourself for endless waves of enemies!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
