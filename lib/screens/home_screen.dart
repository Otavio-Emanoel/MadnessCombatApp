import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/characters.dart' as madness_models;
import 'chest_screen.dart';
import 'character_collection_screen.dart';
import 'game_mode_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int coins = 1000;
  int upgradePoints = 0;
  int unlockedCharacters = 0;
  DateTime? lastClaimed;
  DateTime? lastEasterEggClaimed;
  bool loading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCoins();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Recarrega os dados quando o app voltar ao primeiro plano
      _loadCoins();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega os dados quando as dependências mudarem (ex: voltar para esta tela)
    _loadCoins();
  }

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();

    // Obter valores das preferências
    final newCoins = prefs.getInt('coins') ?? 1000;
    final newUpgradePoints = prefs.getInt('upgradePoints') ?? 0;
    final charList = prefs.getStringList('unlockedCharacters') ?? [];
    final newUnlockedCharacters = charList.length;

    DateTime? newLastClaimed;
    final last = prefs.getString('lastClaimed');
    if (last != null) {
      newLastClaimed = DateTime.tryParse(last);
    }

    DateTime? newLastEasterEggClaimed;
    final lastEgg = prefs.getString('lastEasterEggClaimed');
    if (lastEgg != null) {
      newLastEasterEggClaimed = DateTime.tryParse(lastEgg);
    }

    // Verificar se algum valor mudou antes de chamar setState
    if (loading ||
        coins != newCoins ||
        upgradePoints != newUpgradePoints ||
        unlockedCharacters != newUnlockedCharacters ||
        lastClaimed != newLastClaimed ||
        lastEasterEggClaimed != newLastEasterEggClaimed) {
      setState(() {
        coins = newCoins;
        upgradePoints = newUpgradePoints;
        unlockedCharacters = newUnlockedCharacters;
        lastClaimed = newLastClaimed;
        lastEasterEggClaimed = newLastEasterEggClaimed;
        loading = false;
      });
    }
  }

  Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    if (lastClaimed != null) {
      await prefs.setString('lastClaimed', lastClaimed!.toIso8601String());
    }
    if (lastEasterEggClaimed != null) {
      await prefs.setString(
        'lastEasterEggClaimed',
        lastEasterEggClaimed!.toIso8601String(),
      );
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
                    GestureDetector(
                      onTap: () {
                        _addCoinsEasterEgg();
                        _animationController.forward();
                      },
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Text(
                              'SOMEWHERE IN NEVADA',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: fontSubtitle,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
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
                        child: Column(
                          children: [
                            const Text(
                              "COLLECTION STATS",
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatItem(
                                  context,
                                  '$unlockedCharacters',
                                  'CHARACTERS',
                                  fontStats,
                                  icon: Icons.people,
                                  color: AppColors.purple,
                                  showDetails: true,
                                  details:
                                      '${madness_models.allCharacters.length} total',
                                  onTap: () =>
                                      _navigateToCharactersScreen(context),
                                ),
                                _buildStatItem(
                                  context,
                                  '$upgradePoints',
                                  'UPGRADE POINTS',
                                  fontStats,
                                  icon: Icons.upgrade,
                                  color: AppColors.green,
                                  showDetails: true,
                                  details: 'Use in characters',
                                  onTap: () {
                                    if (unlockedCharacters > 0) {
                                      _navigateToCharactersScreen(context);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Unlock characters first!',
                                          ),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
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
    double fontStats, {
    IconData? icon,
    Color? color,
    bool showDetails = false,
    String? details,
    VoidCallback? onTap,
  }) {
    final displayColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: displayColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            if (icon != null) Icon(icon, color: displayColor, size: 28),
            if (icon != null) const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: displayColor,
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
            if (showDetails && details != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  details,
                  style: TextStyle(
                    color: displayColor.withOpacity(0.7),
                    fontSize: fontStats - 4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
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
            Icons.people_alt,
            'CARDS',
            onTap: () => _navigateToCharactersScreen(context),
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

    // Sempre recarrega os dados ao retornar da tela de baús
    _loadCoins();
  }

  void _navigateToCharactersScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CharacterCollectionScreen(),
      ),
    );

    // Sempre recarrega os dados ao retornar da tela de coleção
    _loadCoins();
  }

  void _navigateToGameScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GameModeScreen()),
    ).then((_) {
      // Recarrega dados ao retornar do jogo
      _loadCoins();
    });
  }

  bool get canClaimEasterEgg {
    if (lastEasterEggClaimed == null) return true;
    final now = DateTime.now();
    return now.difference(lastEasterEggClaimed!).inHours >= 24 ||
        now.day != lastEasterEggClaimed!.day ||
        now.month != lastEasterEggClaimed!.month ||
        now.year != lastEasterEggClaimed!.year;
  }

  void _addCoinsEasterEgg() {
    if (!canClaimEasterEgg) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You already found the Easter Egg today! Come back tomorrow!',
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      coins += 1000;
      lastEasterEggClaimed = DateTime.now();
    });
    _saveCoins();

    // Mostrar um diálogo personalizado com animação
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'EASTER EGG FOUND!',
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
                '+1000 MADNESS COINS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'You discovered the Nevada secret!',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'AWESOME!',
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
}
