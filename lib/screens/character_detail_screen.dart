import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/characters.dart' as madness_models;
import '../utils/constants.dart';

class CharacterDetailScreen extends StatefulWidget {
  final madness_models.Characters character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  State<CharacterDetailScreen> createState() => _CharacterDetailScreenState();
}

class _CharacterDetailScreenState extends State<CharacterDetailScreen> {
  int characterLevel = 1;
  int upgradePoints = 0;
  int powerBonus = 0;
  int defenseBonus = 0;
  int speedBonus = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCharacterStats();
  }

  Future<void> _loadCharacterStats() async {
    final prefs = await SharedPreferences.getInstance();

    // Carregar pontos de upgrade
    final points = prefs.getInt('upgradePoints') ?? 0;

    // Carregar level do personagem
    final level = prefs.getInt('character_${widget.character.name}_level') ?? 1;

    // Carregar bonus de atributos
    final power = prefs.getInt('character_${widget.character.name}_power') ?? 0;
    final defense =
        prefs.getInt('character_${widget.character.name}_defense') ?? 0;
    final speed = prefs.getInt('character_${widget.character.name}_speed') ?? 0;

    setState(() {
      upgradePoints = points;
      characterLevel = level;
      powerBonus = power;
      defenseBonus = defense;
      speedBonus = speed;
      isLoading = false;
    });
  }

  Future<void> _upgradeStat(String stat) async {
    if (upgradePoints <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough upgrade points!'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      upgradePoints--;

      switch (stat) {
        case 'power':
          powerBonus++;
          break;
        case 'defense':
          defenseBonus++;
          break;
        case 'speed':
          speedBonus++;
          break;
      }
    });

    // Salvar as alterações
    await prefs.setInt('upgradePoints', upgradePoints);
    await prefs.setInt(
      'character_${widget.character.name}_$stat',
      stat == 'power'
          ? powerBonus
          : stat == 'defense'
          ? defenseBonus
          : speedBonus,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$stat increased! Points remaining: $upgradePoints'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  Future<void> _upgradeLevel() async {
    // Novo sistema simplificado: custa fixo de 10 pontos por nível
    final requiredPoints = 10;

    if (upgradePoints < requiredPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough upgrade points! Need $requiredPoints points.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Bônus automáticos ao subir de nível com escala progressiva
    final powerIncrement =
        2 + (characterLevel ~/ 3); // Mais bônus em níveis mais altos
    final defenseIncrement = 1 + (characterLevel ~/ 4);
    final speedIncrement = 1 + (characterLevel ~/ 5);

    setState(() {
      upgradePoints -= requiredPoints;
      characterLevel++;

      // Adiciona bônus automáticos
      powerBonus += powerIncrement;
      defenseBonus += defenseIncrement;
      speedBonus += speedIncrement;
    });

    // Salva tudo
    await prefs.setInt('upgradePoints', upgradePoints);
    await prefs.setInt(
      'character_${widget.character.name}_level',
      characterLevel,
    );
    await prefs.setInt('character_${widget.character.name}_power', powerBonus);
    await prefs.setInt(
      'character_${widget.character.name}_defense',
      defenseBonus,
    );
    await prefs.setInt('character_${widget.character.name}_speed', speedBonus);

    // Mostra mensagem com detalhes do upgrade
    _showLevelUpDialog(powerIncrement, defenseIncrement, speedIncrement);
  }

  void _showLevelUpDialog(int powerUp, int defenseUp, int speedUp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'LEVEL UP!',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
                border: Border.all(color: AppColors.secondary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star,
                color: AppColors.secondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Level $characterLevel Reached!',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatBoost('POWER', '+$powerUp', Colors.redAccent),
            const SizedBox(height: 8),
            _buildStatBoost('DEFENSE', '+$defenseUp', Colors.blueAccent),
            const SizedBox(height: 8),
            _buildStatBoost('SPEED', '+$speedUp', Colors.greenAccent),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'AWESOME!',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBoost(String label, String boost, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          boost,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
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
        return const Color(0xFF9D9D9D); // Common
    }
  }

  // Método para obter a cor baseada no tipo de efeito
  Color _getEffectTypeColor(String effectType) {
    switch (effectType.toLowerCase()) {
      case 'damage':
        return Colors.redAccent;
      case 'heal':
        return Colors.greenAccent;
      case 'buff':
        return Colors.blueAccent;
      case 'debuff':
        return Colors.deepPurpleAccent;
      case 'special':
        return Colors.amberAccent;
      default:
        return Colors.grey;
    }
  }

  // Método para obter o rótulo do tipo de efeito
  String _getEffectTypeLabel(String effectType) {
    switch (effectType.toLowerCase()) {
      case 'damage':
        return 'DAMAGE';
      case 'heal':
        return 'HEALING';
      case 'buff':
        return 'BUFF';
      case 'debuff':
        return 'DEBUFF';
      case 'special':
        return 'SPECIAL';
      default:
        return effectType.toUpperCase();
    }
  }

  // Método para mapear strings de nomes de ícones para IconData constantes
  IconData _getIconForAbility(String iconName) {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'sports_martial_arts':
        return Icons.sports_martial_arts;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'crisis_alert':
        return Icons.crisis_alert;
      case 'sentiment_very_dissatisfied':
        return Icons.sentiment_very_dissatisfied;
      case 'rotate_90_degrees_ccw':
        return Icons.rotate_90_degrees_ccw;
      default:
        return Icons.star; // Ícone padrão
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(widget.character.rarity);

    // Calculate total stats with bonuses
    final totalPower = int.parse(widget.character.power) + powerBonus;
    final totalDefense = int.parse(widget.character.defense) + defenseBonus;
    final totalSpeed = int.parse(widget.character.speed) + speedBonus;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagem hero com sobreposição de gradiente
                  Stack(
                    children: [
                      // Imagem
                      SizedBox(
                        height: 340,
                        width: double.infinity,
                        child: Image.asset(
                          widget.character.image,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Gradiente de sobreposição
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.background.withOpacity(0.8),
                                AppColors.background,
                              ],
                              stops: const [0.65, 0.85, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Badge de raridade
                      Positioned(
                        top: 85,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: rarityColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: rarityColor.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            widget.character.rarity.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),

                      // Informações do personagem na parte de baixo da imagem
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.character.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black54,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.secondary,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: AppColors.secondary,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Level $characterLevel',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.purple,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.upgrade,
                                          color: AppColors.purple,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Points: $upgradePoints',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Descrição
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      widget.character.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // Estatísticas
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CHARACTER STATS',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Power
                          _buildStatRow(
                            'POWER',
                            totalPower,
                            powerBonus,
                            Colors.redAccent,
                            onUpgrade: () => _upgradeStat('power'),
                          ),

                          const SizedBox(height: 16),

                          // Defense
                          _buildStatRow(
                            'DEFENSE',
                            totalDefense,
                            defenseBonus,
                            Colors.blueAccent,
                            onUpgrade: () => _upgradeStat('defense'),
                          ),

                          const SizedBox(height: 16),

                          // Speed
                          _buildStatRow(
                            'SPEED',
                            totalSpeed,
                            speedBonus,
                            Colors.greenAccent,
                            onUpgrade: () => _upgradeStat('speed'),
                          ),

                          const SizedBox(height: 16),

                          // Health (Vida)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 90,
                                child: Text(
                                  'HEALTH',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${widget.character.health}',
                                      style: const TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    // Barra de vida
                                    Container(
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 3,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Barra preenchida
                                          FractionallySizedBox(
                                            widthFactor:
                                                1.0, // Sempre cheia inicialmente
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.amber.withOpacity(
                                                      0.6,
                                                    ),
                                                    Colors.amber,
                                                    Colors.amber.withAlpha(240),
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  stops: const [0.0, 0.7, 1.0],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.amber
                                                        .withOpacity(0.6),
                                                    blurRadius: 6,
                                                    spreadRadius: 0,
                                                  ),
                                                ],
                                              ),
                                              // Efeito de brilho na barra
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Stack(
                                                  children: [
                                                    // Brilho no topo da barra
                                                    Positioned(
                                                      top: 0,
                                                      left: 0,
                                                      right: 0,
                                                      height: 5,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.4),
                                                          borderRadius:
                                                              const BorderRadius.only(
                                                                topLeft:
                                                                    Radius.circular(
                                                                      10,
                                                                    ),
                                                                topRight:
                                                                    Radius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Valor centralizado
                                          Positioned.fill(
                                            child: Center(
                                              child: Text(
                                                '${widget.character.health} HP',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  shadows: [
                                                    Shadow(
                                                      blurRadius: 3,
                                                      color: Colors.black,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ), // Espaço para manter alinhamento com outros stats que têm botão
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Special Ability
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SPECIAL ABILITY',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.purple.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.auto_awesome,
                                          color: Colors.purpleAccent,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          widget.character.specialAbility,
                                          style: const TextStyle(
                                            color: Colors.purpleAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      widget
                                          .character
                                          .specialAbilityDescription,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Detalhes da habilidade especial
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        if (widget
                                                .character
                                                .specialAbilityDamage >
                                            0)
                                          _buildAbilityStat(
                                            'Damage',
                                            '${widget.character.specialAbilityDamage}%',
                                            Colors.redAccent,
                                          ),
                                        if (widget
                                                .character
                                                .specialAbilityCooldown >
                                            0)
                                          _buildAbilityStat(
                                            'Cooldown',
                                            '${widget.character.specialAbilityCooldown}s',
                                            Colors.blueAccent,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Habilidades desbloqueáveis
                          if (widget.character.unlockableAbilities.isNotEmpty)
                            _buildUnlockableAbilities(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Level Up Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: upgradePoints >= 10
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: upgradePoints >= 10
                              ? AppColors.secondary
                              : Colors.grey.withOpacity(0.3),
                          foregroundColor: upgradePoints >= 10
                              ? Colors.black
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: upgradePoints >= 10 ? _upgradeLevel : null,
                        icon: Icon(
                          Icons.upgrade,
                          color: upgradePoints >= 10
                              ? Colors.black
                              : Colors.grey.withOpacity(0.7),
                        ),
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'LEVEL UP',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: upgradePoints >= 10
                                    ? Colors.black26
                                    : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.upgrade,
                                    size: 12,
                                    color: upgradePoints >= 10
                                        ? Colors.black
                                        : Colors.grey.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '10 POINTS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: upgradePoints >= 10
                                          ? Colors.black
                                          : Colors.grey.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    // Notificar a tela inicial que os dados podem ter mudado
    // O WidgetsBindingObserver na tela inicial recarregará os dados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Isso forçará a atualização da tela inicial quando voltar para ela
      Navigator.of(context).pop({'dataChanged': true});
    });
    super.dispose();
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      ),
    );
  }

  Widget _buildStatRow(
    String label,
    int value,
    int bonus,
    Color color, {
    required VoidCallback onUpgrade,
  }) {
    // Calcula o valor máximo para a barra (para escala)
    final maxValue =
        150; // Aumentamos o valor máximo para permitir mais crescimento
    // Calcula a porcentagem preenchida (máximo 100%)
    final filledPercentage = (value / maxValue).clamp(0.0, 1.0);

    // Altura dinâmica da barra baseada no valor - barras maiores para stats mais altos
    final baseHeight = 20.0;
    final dynamicHeight = baseHeight + (filledPercentage * 8.0);

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    value.toString(),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (bonus > 0)
                    Text(
                      ' (+$bonus)',
                      style: TextStyle(
                        color: color.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              // Barra de progresso estilizada
              Container(
                height: dynamicHeight, // Barra com altura dinâmica
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 3,
                      spreadRadius: 0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Barra preenchida
                    FractionallySizedBox(
                      widthFactor: filledPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.6),
                              color,
                              color.withAlpha(240),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            stops: const [0.0, 0.7, 1.0],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.6),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        // Adiciona um efeito de brilho na barra
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              // Brilho no topo da barra
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 5,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              // Pulsação de brilho (efeito decorativo)
                              if (value > 80) // Só para valores altos
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          color.withOpacity(0.6),
                                          color.withOpacity(0.0),
                                        ],
                                        radius: 0.8,
                                        center: Alignment.center,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Indicadores de valor na barra (divisões)
                    Positioned.fill(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          10, // Mais divisões
                          (index) => Container(
                            width: 1,
                            color: Colors.white24,
                            margin: EdgeInsets.symmetric(vertical: 3),
                          ),
                        ),
                      ),
                    ),
                    // Valor numérico centralizado na barra
                    Positioned.fill(
                      child: Center(
                        child: Text(
                          value.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: filledPercentage > 0.3 ? 12 : 10,
                            shadows: [
                              Shadow(
                                blurRadius: 3,
                                color: Colors.black,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: upgradePoints > 0 ? onUpgrade : null,
          icon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: upgradePoints > 0
                  ? color.withOpacity(0.2)
                  : Colors.transparent,
            ),
            padding: const EdgeInsets.all(2),
            child: Icon(
              Icons.add_circle,
              color: upgradePoints > 0 ? color : Colors.grey.withOpacity(0.5),
              size: 26,
            ),
          ),
          tooltip: 'Upgrade $label',
        ),
      ],
    );
  }

  // Método para mostrar as habilidades desbloqueáveis
  Widget _buildUnlockableAbilities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'UNLOCKABLE ABILITIES',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.character.unlockableAbilities.map((ability) {
          final isUnlocked = characterLevel >= ability.levelRequired;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.surface.withOpacity(0.5)
                  : Colors.black45,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isUnlocked
                    ? AppColors.purple.withOpacity(0.7)
                    : Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? AppColors.purple.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    // Usar ícones predefinidos baseados no nome da string
                    _getIconForAbility(ability.icon),
                    color: isUnlocked ? AppColors.purple : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            ability.name,
                            style: TextStyle(
                              color: isUnlocked ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? AppColors.green.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isUnlocked
                                  ? 'UNLOCKED'
                                  : 'Level ${ability.levelRequired}',
                              style: TextStyle(
                                color: isUnlocked
                                    ? AppColors.green
                                    : Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ability.description,
                        style: TextStyle(
                          color: isUnlocked
                              ? Colors.white70
                              : Colors.grey.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),

                      // Mostrar detalhes adicionais de dano, cooldown e duração
                      if (isUnlocked)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Badge de tipo de efeito
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getEffectTypeColor(
                                    ability.effectType,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getEffectTypeLabel(ability.effectType),
                                  style: TextStyle(
                                    color: _getEffectTypeColor(
                                      ability.effectType,
                                    ),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              // Stats da habilidade
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (ability.damageBonus > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _buildAbilityStat(
                                        'Damage',
                                        '${ability.damageBonus}${ability.damageBonus < 100 ? '%' : ''}',
                                        Colors.redAccent,
                                      ),
                                    ),
                                  if (ability.cooldown > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: _buildAbilityStat(
                                        'Cooldown',
                                        '${ability.cooldown}s',
                                        Colors.blueAccent,
                                      ),
                                    ),
                                  if (ability.effectDuration > 0)
                                    _buildAbilityStat(
                                      'Duration',
                                      '${ability.effectDuration}s',
                                      Colors.greenAccent,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // Método para exibir estatísticas das habilidades
  Widget _buildAbilityStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
