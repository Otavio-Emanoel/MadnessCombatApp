import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chest_type.dart';
import '../models/characters.dart' as madness_models;
import '../utils/constants.dart';

class ChestScreen extends StatefulWidget {
  final int coins;
  final Function(int) onCoinsChanged;
  const ChestScreen({
    super.key,
    required this.coins,
    required this.onCoinsChanged,
  });

  @override
  State<ChestScreen> createState() => _ChestScreenState();
}

class _ChestScreenState extends State<ChestScreen>
    with SingleTickerProviderStateMixin {
  bool isOpening = false;
  ChestType? openedChest;
  String? rewardMessage;
  madness_models.Characters? rewardedCharacter;
  int coins = 0;
  int upgradePoints = 0;

  // Para animação do card
  late AnimationController _cardController;
  late Animation<double> _cardRotation;
  bool showCharacterCard = false;

  @override
  void initState() {
    super.initState();
    coins = widget.coins;

    // Inicializar controlador de animação
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _cardRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeInOutBack),
    );

    _cardController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          showCharacterCard = true;
        });
      }
    });

    // Carregar pontos de upgrade salvos
    _loadUpgradePoints();
  }

  Future<void> _loadUpgradePoints() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      upgradePoints = prefs.getInt('upgradePoints') ?? 0;
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
  }

  Future<void> _openChest(ChestType chest) async {
    if (isOpening || coins < chest.price) return;

    setState(() {
      isOpening = true;
      openedChest = chest;
      rewardMessage = null;
      rewardedCharacter = null;
      showCharacterCard = false;
    });

    // Animação inicial do baú
    await Future.delayed(const Duration(milliseconds: 1200));

    // Selecionar uma recompensa aleatória
    final random = Random();

    // Selecionar um personagem baseado na raridade do baú
    List<madness_models.Characters> availableCharacters = [];
    String chestRarity = chest.name.toLowerCase();

    if (chestRarity == 'common') {
      // Common and uncommon characters
      availableCharacters = madness_models.allCharacters
          .where((c) => c.rarity == 'Common' || c.rarity == 'Uncommon')
          .toList();
    } else if (chestRarity == 'rare') {
      // Rare and epic characters (lower chance)
      availableCharacters = madness_models.allCharacters
          .where(
            (c) =>
                c.rarity == 'Rare' ||
                (c.rarity == 'Epic' && random.nextDouble() < 0.4),
          )
          .toList();
    } else if (chestRarity == 'legendary') {
      // Epic and legendary characters (lower chance)
      availableCharacters = madness_models.allCharacters
          .where(
            (c) =>
                c.rarity == 'Epic' ||
                (c.rarity == 'Legendary' && random.nextDouble() < 0.3),
          )
          .toList();
    }

    // Make sure we have available characters
    if (availableCharacters.isEmpty) {
      availableCharacters = madness_models.allCharacters
          .where((c) => c.rarity == 'Common')
          .toList();
    }

    // Select a random character
    final selectedCharacter =
        availableCharacters[random.nextInt(availableCharacters.length)];

    // Add upgrade points too
    int upgradePointsEarned = 0;
    if (chestRarity == 'common') {
      upgradePointsEarned = random.nextInt(5) + 1; // 1-5 points
    } else if (chestRarity == 'rare') {
      upgradePointsEarned = random.nextInt(10) + 5; // 5-15 points
    } else if (chestRarity == 'legendary') {
      upgradePointsEarned = random.nextInt(20) + 10; // 10-30 points
    }

    setState(() {
      coins -= chest.price;
      upgradePoints += upgradePointsEarned;
      rewardedCharacter = selectedCharacter;

      // Mensagem baseada na raridade do personagem
      String rarityMessage = '';
      if (selectedCharacter.rarity == 'Legendary') {
        rarityMessage = 'LEGENDARY';
      } else if (selectedCharacter.rarity == 'Epic') {
        rarityMessage = 'EPIC';
      } else if (selectedCharacter.rarity == 'Rare') {
        rarityMessage = 'RARE';
      } else if (selectedCharacter.rarity == 'Uncommon') {
        rarityMessage = 'UNCOMMON';
      } else {
        rarityMessage = 'COMMON';
      }

      rewardMessage =
          'You got a $rarityMessage character!\nAnd $upgradePointsEarned upgrade points!';
    });

    // Iniciar animação da carta
    _cardController.reset();
    _cardController.forward();

    // Atualizar coins e salvar
    widget.onCoinsChanged(coins);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);

    // Salvar os pontos de upgrade
    final currentPoints = prefs.getInt('upgradePoints') ?? 0;
    await prefs.setInt('upgradePoints', currentPoints + upgradePointsEarned);

    // Registrar o personagem como desbloqueado
    final unlockedCharacters = prefs.getStringList('unlockedCharacters') ?? [];
    if (!unlockedCharacters.contains(selectedCharacter.name)) {
      unlockedCharacters.add(selectedCharacter.name);
      await prefs.setStringList('unlockedCharacters', unlockedCharacters);
    }

    // Mostrar notificação sobre pontos ganhos
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.upgrade, color: Colors.white),
            const SizedBox(width: 12),
            Text('You got $upgradePointsEarned upgrade points!'),
          ],
        ),
        backgroundColor: AppColors.purple,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Aguardar um tempo antes de completar a animação
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      isOpening = false;
    });

    // Mostrar o modal do personagem automaticamente
    await Future.delayed(const Duration(milliseconds: 500));
    _showCharacterCardModal(context);
  }

  @override
  Widget build(BuildContext context) {
    final chests = ChestType.chests;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chests'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Coins: $coins', style: AppTextStyles.subtitle),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.purple.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.upgrade,
                        color: AppColors.purple,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Upgrade Points: $upgradePoints',
                        style: const TextStyle(
                          color: AppColors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: chests.length,
                itemBuilder: (context, idx) {
                  final chest = chests[idx];
                  final isThisOpening = isOpening && openedChest == chest;
                  return Card(
                    color: chest.color.withOpacity(0.15),
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: chest.color, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            height: isThisOpening ? 120 : 100,
                            width: isThisOpening ? 120 : 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: chest.color, width: 2),
                              boxShadow: isThisOpening
                                  ? [
                                      BoxShadow(
                                        color: chest.color.withOpacity(0.4),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Image.asset(
                                    chest.image,
                                    fit: BoxFit.cover,
                                    colorBlendMode: isThisOpening
                                        ? BlendMode.overlay
                                        : null,
                                    color: isThisOpening
                                        ? chest.color.withOpacity(0.5)
                                        : null,
                                  ),
                                ),
                                if (isThisOpening)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(13),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            chest.color.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.auto_awesome,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${chest.name} Chest',
                            style: AppTextStyles.title,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person, color: chest.color, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Representado por: ${chest.representativeCharacter}',
                                style: TextStyle(
                                  color: chest.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Price: ${chest.price} coins',
                            style: AppTextStyles.body,
                          ),
                          Text(
                            'Character chance: ${(chest.chance * 100).toStringAsFixed(0)}%',
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: chest.color,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isOpening || coins < chest.price
                                ? null
                                : () => _openChest(chest),
                            child: isThisOpening
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Open Chest'),
                          ),
                          if (isThisOpening && rewardMessage == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Opening...',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          if (openedChest == chest && rewardMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                rewardMessage!,
                                style: TextStyle(
                                  color: _getRewardColor(
                                    rewardedCharacter?.rarity ?? '',
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          if (openedChest == chest && rewardedCharacter != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getRarityColor(
                                    rewardedCharacter!.rarity,
                                  ).withOpacity(0.7),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 20,
                                  ),
                                ),
                                onPressed: () {
                                  _showCharacterCardModal(context);
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.visibility, color: Colors.white),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "VIEW CHARACTER CARD",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRewardColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return Colors.amber;
      case 'epic':
        return Colors.purpleAccent;
      case 'rare':
        return Colors.blueAccent;
      case 'uncommon':
        return Colors.greenAccent;
      default:
        return Colors.white70;
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return const Color(0xFFFFD700);
      case 'epic':
        return const Color(0xFFA335EE);
      case 'rare':
        return const Color(0xFF0070DD);
      case 'uncommon':
        return const Color(0xFF1EFF00);
      default:
        return const Color(0xFF9D9D9D);
    }
  }

  void _showCharacterCardModal(BuildContext context) {
    if (rewardedCharacter == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: AnimatedBuilder(
              animation: _cardController,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(!showCharacterCard ? _cardRotation.value : 0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getRarityColor(rewardedCharacter!.rarity),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getRarityColor(
                            rewardedCharacter!.rarity,
                          ).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Cabeçalho com a raridade
                            Container(
                              width: double.infinity,
                              color: _getRarityColor(
                                rewardedCharacter!.rarity,
                              ).withOpacity(0.8),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Text(
                                  rewardedCharacter!.rarity.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),

                            // Nome do personagem
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    rewardedCharacter!.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  // Health indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade800.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.red.shade800.withOpacity(
                                          0.5,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          color: Colors.red.shade800,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "HEALTH: ${rewardedCharacter!.health}",
                                          style: TextStyle(
                                            color: Colors.red.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Imagem do personagem
                            Container(
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: _getRarityColor(
                                      rewardedCharacter!.rarity,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                  bottom: BorderSide(
                                    color: _getRarityColor(
                                      rewardedCharacter!.rarity,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Image.asset(
                                rewardedCharacter!.image,
                                fit: BoxFit.contain,
                              ),
                            ),

                            // Descrição
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    rewardedCharacter!.description,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  // Badge de pontos de upgrade ganhos
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.purple.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.purple.withOpacity(
                                          0.5,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.upgrade,
                                          color: AppColors.purple,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        RichText(
                                          text: TextSpan(
                                            text: '+',
                                            style: const TextStyle(
                                              color: AppColors.purple,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: openedChest != null
                                                    ? (openedChest!.name
                                                                  .toLowerCase() ==
                                                              'common'
                                                          ? '1-5'
                                                          : openedChest!.name
                                                                    .toLowerCase() ==
                                                                'rare'
                                                          ? '5-15'
                                                          : '10-30')
                                                    : '??',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const TextSpan(
                                                text: ' UPGRADE POINTS',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Status
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Column(
                                children: [
                                  _buildStatRow(
                                    'HEALTH',
                                    rewardedCharacter!.health.toString(),
                                  ),
                                  _buildStatRow(
                                    'TYPE',
                                    rewardedCharacter!.type,
                                  ),
                                  _buildStatRow(
                                    'POWER',
                                    rewardedCharacter!.power,
                                  ),
                                  _buildStatRow(
                                    'DEFENSE',
                                    rewardedCharacter!.defense,
                                  ),
                                  _buildStatRow(
                                    'SPEED',
                                    rewardedCharacter!.speed,
                                  ),
                                  _buildStatRow(
                                    'SPECIAL',
                                    rewardedCharacter!.specialAbility,
                                  ),
                                  _buildStatRow(
                                    'LEVEL',
                                    rewardedCharacter!.level,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Botão para fechar
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _getRarityColor(
                                    rewardedCharacter!.rarity,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "AWESOME!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ).then((_) {
      if (!showCharacterCard) {
        setState(() {
          showCharacterCard = true;
        });
      }
    });

    // Iniciar a animação quando o modal for exibido
    if (!showCharacterCard) {
      _cardController.reset();
      _cardController.forward();
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
