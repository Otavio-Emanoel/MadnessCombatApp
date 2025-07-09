import 'package:flutter/material.dart';
import '../utils/constants.dart';



class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingLarge),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildLogo(),
                  const SizedBox(height: 10),
                  const Text(
                    'SOMEWHERE IN NEVADA',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            ),

            // Daily coins and chest section
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingLarge,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Daily Reward Button
                    _buildFeatureButton(
                      context,
                      icon: Icons.calendar_today,
                      title: 'DAILY REWARD',
                      subtitle: 'Collect your Madness Coins',
                      color: AppColors.purple,
                      onTap: () {
                        // Show daily reward dialog
                        _showDailyRewardDialog(context);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Chest Button
                    _buildFeatureButton(
                      context,
                      icon: Icons.lock,
                      title: 'CHEST',
                      subtitle: 'Unlock new characters',
                      color: AppColors.orange,
                      onTap: () {
                        // Navigate to chest screen
                        _navigateToChestScreen(context);
                      },
                    ),

                    const SizedBox(height: 20),

                    // Stats Display
                    Container(
                      padding: EdgeInsets.all(AppDimensions.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.borderRadiusMedium,
                        ),
                        border: Border.all(
                          color: const Color(0xFF2C2C2C),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(context, '145', 'KILLS'),
                          _buildStatItem(context, '27', 'CHARACTERS'),
                          _buildStatItem(context, '3150', 'COINS'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: Color(0xFF2C2C2C), width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton(
                    context,
                    Icons.home,
                    'HOME',
                    isSelected: true,
                    onTap: () {},
                  ),
                  _buildNavButton(
                    context,
                    Icons.quiz,
                    'QUIZ',
                    onTap: () {
                      _navigateToQuizScreen(context);
                    },
                  ),
                  _buildNavButton(
                    context,
                    Icons.sports_esports,
                    'GAME',
                    onTap: () {
                      _navigateToGameScreen(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 150,
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Image(
        image: AssetImage('assets/images/icons/icon.png'),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingMedium,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusMedium,
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            SizedBox(width: AppDimensions.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.button),
                  Text(subtitle, style: AppTextStyles.body),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: AppTextStyles.body),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context,
    IconData icon,
    String label, {
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingLarge,
          vertical: AppDimensions.paddingSmall,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(
                  AppDimensions.borderRadiusSmall,
                ),
                border: const Border(
                  top: BorderSide(color: AppColors.primary, width: 3),
                ),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyRewardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'DAILY REWARD',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2C2C2C),
                border: Border.all(color: AppColors.secondary, width: 2),
              ),
              child: const Icon(
                Icons.monetization_on,
                color: AppColors.secondary,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '100 MADNESS COINS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text('Come back tomorrow for more!', style: AppTextStyles.body),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CLAIM',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChestScreen(BuildContext context) {
    // Aqui seria a navegação para a tela do baú
    // Por enquanto apenas mostra um SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chest Screen will be implemented soon!'),
        backgroundColor: AppColors.orange,
      ),
    );
  }

  void _navigateToQuizScreen(BuildContext context) {
    // Aqui seria a navegação para a tela de quiz
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quiz Screen will be implemented soon!'),
        backgroundColor: AppColors.purple,
      ),
    );
  }

  void _navigateToGameScreen(BuildContext context) {
    // Aqui seria a navegação para a tela do jogo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mini Game Screen will be implemented soon!'),
        backgroundColor: AppColors.green,
      ),
    );
  }
}
