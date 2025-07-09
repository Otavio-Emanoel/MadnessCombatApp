import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'chest_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int coins = 1000;
  DateTime? lastClaimed;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 1000;
      final last = prefs.getString('lastClaimed');
      if (last != null) {
        lastClaimed = DateTime.tryParse(last);
      }
      loading = false;
    });
  }

  Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    if (lastClaimed != null) {
      await prefs.setString('lastClaimed', lastClaimed!.toIso8601String());
    }
  }

  bool get canClaimDaily {
    if (lastClaimed == null) return true;
    final now = DateTime.now();
    return now.difference(lastClaimed!).inHours >= 24 ||
        now.day != lastClaimed!.day ||
        now.month != lastClaimed!.month ||
        now.year != lastClaimed!.year;
  }

  Future<void> _claimDailyReward() async {
    if (!canClaimDaily) return;
    setState(() {
      coins += 100;
      lastClaimed = DateTime.now();
    });
    await _saveCoins();
    _showDailyRewardDialog(context, claimed: true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 400;
    final padding = isSmall ? 12.0 : 24.0;
    final logoSize = isSmall ? 90.0 : 140.0;
    final cardRadius = isSmall ? 16.0 : 24.0;
    final cardBlur = isSmall ? 8.0 : 18.0;
    final fontTitle = isSmall ? 18.0 : 26.0;
    final fontSubtitle = isSmall ? 12.0 : 16.0;
    final fontStats = isSmall ? 14.0 : 18.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings will be implemented soon!'),
                          backgroundColor: AppColors.secondary,
                        ),
                      );
                    },
                  ),
                  _totalCoins(context, coins, fontStats),
                ],
              ),
            ),
          ),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding + 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 24),
                    _buildLogo(logoSize),
                    SizedBox(height: 16),
                    Text(
                      'SOMEWHERE IN NEVADA',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: fontSubtitle,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 32),
                    _glassCard(
                      context,
                      radius: cardRadius,
                      blur: cardBlur,
                      child: Column(
                        children: [
                          _buildFeatureButton(
                            context,
                            icon: Icons.calendar_today,
                            title: 'DAILY REWARD',
                            subtitle: canClaimDaily
                                ? 'Collect your Madness Coins'
                                : 'Come back tomorrow',
                            color: AppColors.purple,
                            onTap: canClaimDaily ? _claimDailyReward : null,
                            fontTitle: fontTitle,
                            fontSubtitle: fontSubtitle,
                            enabled: canClaimDaily,
                          ),
                          SizedBox(height: 16),
                          _buildFeatureButton(
                            context,
                            icon: Icons.lock,
                            title: 'CHEST',
                            subtitle: 'Unlock new characters',
                            color: AppColors.orange,
                            onTap: () => _navigateToChestScreen(context),
                            fontTitle: fontTitle,
                            fontSubtitle: fontSubtitle,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    _glassCard(
                      context,
                      radius: cardRadius,
                      blur: cardBlur,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(context, '145', 'KILLS', fontStats),
                            _buildStatItem(
                              context,
                              '27',
                              'CHARACTERS',
                              fontStats,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    _modernNavBar(context, fontStats),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLogo(double size) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface.withOpacity(0.7),
        border: Border.all(color: AppColors.primary, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 18,
            spreadRadius: 6,
          ),
        ],
      ),
      child: const Image(
        image: AssetImage('assets/images/icons/icon.png'),
        fit: BoxFit.cover,
        width: 90,
        height: 90,
      ),
    );
  }

  Widget _glassCard(
    BuildContext context, {
    required Widget child,
    double radius = 24,
    double blur = 18,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: blur,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: child,
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback? onTap,
    double fontTitle = 22,
    double fontSubtitle = 14,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      splashColor: color.withOpacity(0.2),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: fontTitle,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontSize: fontSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    double fontStats,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: fontStats + 6,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: fontStats,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _totalCoins(BuildContext context, int coins, double fontStats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on,
            color: AppColors.secondary,
            size: 22,
          ),
          const SizedBox(width: 6),
          Text(
            '$coins',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: fontStats + 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernNavBar(BuildContext context, double fontStats) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            onTap: () => _navigateToQuizScreen(context),
          ),
          _buildNavButton(
            context,
            Icons.sports_esports,
            'GAME',
            onTap: () => _navigateToGameScreen(context),
          ),
        ],
      ),
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

  void _showDailyRewardDialog(BuildContext context, {bool claimed = false}) {
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
        content: SingleChildScrollView(
          child: Column(
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
              Text(
                claimed
                    ? 'Coins added to your account!'
                    : 'Come back tomorrow for more!',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
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

  void _navigateToChestScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChestScreen(
          coins: coins,
          onCoinsChanged: (newCoins) {
            setState(() {
              coins = newCoins;
            });
            _saveCoins();
          },
        ),
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
