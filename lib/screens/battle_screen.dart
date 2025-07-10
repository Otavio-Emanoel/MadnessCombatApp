import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/characters.dart' as madness_models;
import '../models/battle_system.dart';
import '../utils/constants.dart';

class BattleScreen extends StatefulWidget {
  final List<madness_models.Characters> playerTeam;
  final bool isCampaign;
  final int? campaignLevel;

  const BattleScreen({
    super.key,
    required this.playerTeam,
    this.isCampaign = false,
    this.campaignLevel,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen>
    with TickerProviderStateMixin {
  late BattleManager battleManager;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  BattleCharacter? selectedCharacter;
  BattleCharacter? selectedTarget;
  ActionType? selectedAction;
  String? selectedAbility;

  List<String> currentTurnLog = [];
  bool isExecutingActions = false;
  bool battleEnded = false;

  @override
  void initState() {
    super.initState();
    _initializeBattle();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeBattle() {
    // Criar equipe do jogador
    List<BattleCharacter> playerBattleChars = widget.playerTeam
        .map((char) => BattleCharacter(character: char))
        .toList();

    BattleTeam playerTeam = BattleTeam(
      characters: playerBattleChars,
      teamName: "Player Team",
      isPlayerTeam: true,
    );

    // Gerar equipe inimiga
    BattleTeam enemyTeam;
    if (widget.isCampaign && widget.campaignLevel != null) {
      enemyTeam = _generateCampaignEnemyTeam(widget.campaignLevel!);
    } else {
      enemyTeam = BattleManager.generateBalancedEnemyTeam(
        widget.playerTeam,
        madness_models.allCharacters,
      );
    }

    battleManager = BattleManager(playerTeam: playerTeam, enemyTeam: enemyTeam);
    battleManager.startBattle();
  }

  BattleTeam _generateCampaignEnemyTeam(int level) {
    // Gerar inimigos baseados no nível da campanha
    List<madness_models.Characters> campaignEnemies = [];

    // Seleção de inimigos baseada no nível
    if (level <= 3) {
      // Níveis iniciais: apenas grunts e agentes básicos
      campaignEnemies = madness_models.allCharacters
          .where((char) => char.rarity == 'Common' || char.rarity == 'Uncommon')
          .take(3)
          .toList();
    } else if (level <= 7) {
      // Níveis médios: mix de raros e épicos
      campaignEnemies = madness_models.allCharacters
          .where((char) => ['Rare', 'Epic'].contains(char.rarity))
          .take(3)
          .toList();
    } else {
      // Níveis altos: épicos e lendários
      campaignEnemies = madness_models.allCharacters
          .where((char) => ['Epic', 'Legendary'].contains(char.rarity))
          .take(3)
          .toList();
    }

    // Se não encontrou inimigos suficientes, usar qualquer um
    if (campaignEnemies.length < 3) {
      campaignEnemies = madness_models.allCharacters.take(3).toList();
    }

    List<BattleCharacter> battleChars = campaignEnemies
        .map((char) => BattleCharacter(character: char))
        .toList();

    return BattleTeam(
      characters: battleChars,
      teamName: "Campaign Level $level",
      isPlayerTeam: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header com informações da batalha
              _buildBattleHeader(),

              // Área da batalha (equipes)
              Expanded(flex: 3, child: _buildBattleField()),

              // Log de batalha
              _buildBattleLog(),

              // Controles de ação
              if (!battleEnded) _buildActionControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBattleHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isCampaign
                    ? 'Campaign Level ${widget.campaignLevel}'
                    : 'Random Battle',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Turn ${battleManager.currentTurn}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => _showExitDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Equipe inimiga (no topo)
          _buildTeamRow(battleManager.enemyTeam, isEnemyTeam: true),

          const SizedBox(height: 20),

          // Divisor central
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primary,
                  Colors.transparent,
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Equipe do jogador (embaixo)
          _buildTeamRow(battleManager.playerTeam, isEnemyTeam: false),
        ],
      ),
    );
  }

  Widget _buildTeamRow(BattleTeam team, {required bool isEnemyTeam}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            team.teamName,
            style: TextStyle(
              color: isEnemyTeam ? Colors.red : AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: team.characters.map((battleChar) {
                return _buildCharacterCard(
                  battleChar,
                  isEnemyTeam: isEnemyTeam,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(
    BattleCharacter battleChar, {
    required bool isEnemyTeam,
  }) {
    bool isSelected =
        selectedCharacter == battleChar || selectedTarget == battleChar;
    bool isKnockedOut = battleChar.isKnockedOut;

    return GestureDetector(
      onTap: () => _onCharacterTapped(battleChar, isEnemyTeam),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isKnockedOut
                ? Colors.red
                : _getRarityColor(battleChar.character.rarity),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: Image.asset(
                      battleChar.character.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      color: isKnockedOut ? Colors.black54 : null,
                      colorBlendMode: isKnockedOut ? BlendMode.srcATop : null,
                    ),
                  ),
                  if (isKnockedOut)
                    const Positioned.fill(
                      child: Center(
                        child: Icon(Icons.close, color: Colors.red, size: 30),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Text(
                      battleChar.character.name,
                      style: TextStyle(
                        color: isKnockedOut ? Colors.white38 : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Barra de vida
                    _buildHealthBar(battleChar),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBar(BattleCharacter battleChar) {
    double healthPercent =
        battleChar.currentHealth / battleChar.character.health;

    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: healthPercent,
            child: Container(
              decoration: BoxDecoration(
                color: healthPercent > 0.6
                    ? Colors.green
                    : healthPercent > 0.3
                    ? Colors.orange
                    : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${battleChar.currentHealth}/${battleChar.character.health}',
          style: const TextStyle(color: Colors.white70, fontSize: 8),
        ),
      ],
    );
  }

  Widget _buildBattleLog() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Battle Log',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: currentTurnLog
                    .map(
                      (log) => Text(
                        log,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionControls() {
    if (selectedCharacter == null || selectedCharacter!.isKnockedOut) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          'Select an available character to perform actions',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com personagem selecionado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getRarityColor(
                        selectedCharacter!.character.rarity,
                      ),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      selectedCharacter!.character.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCharacter!.character.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'HP: ${selectedCharacter!.currentHealth}/${selectedCharacter!.character.health}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      // Stats rápidos
                      Text(
                        'ATK: ${selectedCharacter!.totalPower} | DEF: ${selectedCharacter!.totalDefense} | SPD: ${selectedCharacter!.totalSpeed}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Ações básicas
          const Text(
            'Basic Actions:',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildActionButton(
                'Basic Attack',
                Icons.gps_fixed,
                Colors.red,
                () => _selectAction(ActionType.attack),
                description: 'Standard weapon attack',
              ),
              _buildActionButton(
                'Defend',
                Icons.shield,
                Colors.blue,
                () => _selectAction(ActionType.defend),
                description: 'Reduce damage by 50%',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Habilidade especial do personagem
          const Text(
            'Special Ability:',
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),

          _buildSpecialAbilityCard(),

          // Mostrar habilidades desbloqueáveis disponíveis
          if (selectedCharacter!.character.unlockableAbilities.isNotEmpty)
            _buildUnlockableAbilities(),

          const SizedBox(height: 16),

          // Seleção de alvo
          if (selectedAction == ActionType.attack ||
              selectedAction == ActionType.specialAbility)
            _buildTargetSelection(),

          const SizedBox(height: 16),

          // Botão de executar turno
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    (battleManager.pendingActions.isNotEmpty &&
                        !isExecutingActions)
                    ? AppColors.primary
                    : Colors.grey.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed:
                  battleManager.pendingActions.isNotEmpty && !isExecutingActions
                  ? _executeCurrentTurn
                  : null,
              icon: isExecutingActions
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                isExecutingActions
                    ? 'Executing Actions...'
                    : 'EXECUTE TURN (${battleManager.pendingActions.length}/${battleManager.playerTeam.aliveCharacters.length})',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.my_location, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Choose your target:',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Lista horizontal de inimigos selecionáveis
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: battleManager.enemyTeam.aliveCharacters.length,
              itemBuilder: (context, index) {
                var enemy = battleManager.enemyTeam.aliveCharacters[index];
                bool isSelected = selectedTarget == enemy;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTarget = enemy;
                      _addActionToQueue();
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected 
                          ? Colors.orange 
                          : _getRarityColor(enemy.character.rarity),
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ] : null,
                    ),
                    child: Column(
                      children: [
                        // Imagem do inimigo
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            child: Image.asset(
                              enemy.character.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        ),
                        // Info do inimigo
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              children: [
                                Text(
                                  enemy.character.name.length > 8
                                    ? '${enemy.character.name.substring(0, 8)}...'
                                    : enemy.character.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                // Mini barra de vida
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: enemy.currentHealth / enemy.character.health,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${enemy.currentHealth}/${enemy.character.health}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.orange : Colors.white70,
                                    fontSize: 8,
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
          
          if (selectedTarget != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Target: ${selectedTarget!.character.name} - '
                      'Type: ${selectedTarget!.character.type} - '
                      'Power: ${selectedTarget!.totalPower}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Tap on an enemy above to select your target',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool enabled = true,
    String? description,
    int? cooldown,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: enabled
                ? color.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: enabled ? color : Colors.grey, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: enabled ? color : Colors.grey),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: enabled ? color : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: enabled ? Colors.white70 : Colors.grey,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (cooldown != null && cooldown > 0) ...[
                const SizedBox(height: 2),
                Text(
                  'Cooldown: $cooldown',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockableAbilities() {
    if (selectedCharacter == null) return const SizedBox.shrink();

    var availableAbilities = selectedCharacter!.character.unlockableAbilities
        .where(
          (ability) =>
              int.parse(selectedCharacter!.character.level) >=
              ability.levelRequired,
        )
        .toList();

    if (availableAbilities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Text(
          'Unlocked Abilities:',
          style: TextStyle(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: availableAbilities.length,
            itemBuilder: (context, index) {
              var ability = availableAbilities[index];
              bool canUse = selectedCharacter!.canUseAbility(ability.name);

              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: canUse
                      ? AppColors.secondary.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: canUse ? AppColors.secondary : Colors.grey,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getAbilityIcon(ability.icon),
                      color: canUse ? AppColors.secondary : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ability.name,
                      style: TextStyle(
                        color: canUse ? AppColors.secondary : Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!canUse) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Cooldown: ${selectedCharacter!.cooldowns[ability.name] ?? 0}',
                        style: const TextStyle(color: Colors.red, fontSize: 8),
                      ),
                    ],
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _getAbilityIcon(String iconName) {
    switch (iconName) {
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'sports_martial_arts':
        return Icons.sports_martial_arts;
      case 'health_and_safety':
        return Icons.health_and_safety;
      case 'flash_on':
        return Icons.flash_on;
      case 'psychology':
        return Icons.psychology;
      case 'shield':
        return Icons.shield;
      case 'gavel':
        return Icons.gavel;
      case 'bolt':
        return Icons.bolt;
      case 'speed':
        return Icons.speed;
      default:
        return Icons.auto_awesome;
    }
  }

  Widget _buildSpecialAbilityCard() {
    if (selectedCharacter == null) return const SizedBox.shrink();

    bool canUse = selectedCharacter!.canUseAbility(
      selectedCharacter!.character.specialAbility,
    );
    int? cooldown = selectedCharacter!.cooldowns[
      selectedCharacter!.character.specialAbility
    ];

    return GestureDetector(
      onTap: canUse ? () => _selectAction(ActionType.specialAbility) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: canUse
              ? Colors.purple.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canUse ? Colors.purple : Colors.grey,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: canUse ? Colors.purple : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedCharacter!.character.specialAbility,
                    style: TextStyle(
                      color: canUse ? Colors.purple : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (cooldown != null && cooldown > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Cooldown: $cooldown',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              selectedCharacter!.character.specialAbilityDescription,
              style: TextStyle(
                color: canUse ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (selectedCharacter!.character.specialAbilityDamage > 0) ...[
                  Icon(
                    Icons.flash_on,
                    color: Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Damage: +${selectedCharacter!.character.specialAbilityDamage}%',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (selectedCharacter!.character.specialAbilityCooldown > 0) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.timer,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Cooldown: ${selectedCharacter!.character.specialAbilityCooldown}s',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
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
        return const Color(0xFF9D9D9D);
    }
  }

  void _onCharacterTapped(BattleCharacter battleChar, bool isEnemyTeam) {
    setState(() {
      if (isEnemyTeam) {
        // Selecionar alvo inimigo
        if (selectedAction == ActionType.attack ||
            selectedAction == ActionType.specialAbility) {
          selectedTarget = battleChar;
          _addActionToQueue();
        }
      } else {
        // Selecionar personagem do jogador
        if (!battleChar.isKnockedOut) {
          selectedCharacter = battleChar;
          selectedTarget = null;
          selectedAction = null;
        }
      }
    });
  }

  void _selectAction(ActionType action) {
    setState(() {
      selectedAction = action;
      selectedTarget = null;

      if (action == ActionType.defend) {
        // Defender não precisa de alvo
        _addActionToQueue();
      }
    });
  }

  void _addActionToQueue() {
    if (selectedCharacter == null || selectedAction == null) return;

    BattleAction action = BattleAction(
      user: selectedCharacter!,
      type: selectedAction!,
      target: selectedTarget,
      abilityName: selectedAction == ActionType.specialAbility
          ? selectedCharacter!.character.specialAbility
          : null,
    );

    battleManager.addAction(action);

    setState(() {
      selectedCharacter = null;
      selectedTarget = null;
      selectedAction = null;
    });

    // Se todas as ações foram adicionadas, executar automaticamente
    if (battleManager.pendingActions.length >=
        battleManager.playerTeam.aliveCharacters.length) {
      _executeCurrentTurn();
    }
  }

  void _executeCurrentTurn() async {
    setState(() {
      isExecutingActions = true;
    });

    // Adicionar ações da IA para inimigos
    _addEnemyActions();

    List<String> turnLog = battleManager.executeActions();

    setState(() {
      currentTurnLog = turnLog;
      isExecutingActions = false;
    });

    // Verificar se a batalha terminou
    BattleResult? result = battleManager.getBattleResult();
    if (result != null) {
      setState(() {
        battleEnded = true;
      });
      _showBattleResult(result);
    }
  }

  void _addEnemyActions() {
    // Usar o novo sistema de IA estratégica
    List<String> enemyTurnLog = battleManager.executeEnemyTurn();
    
    // Adicionar os logs de decisão da IA ao log de batalha
    currentTurnLog.addAll(enemyTurnLog);
  }

  void _showBattleResult(BattleResult result) {
    String title;
    String message;
    Color color;
    int coinsEarned = 0;

    switch (result) {
      case BattleResult.victory:
        title = 'VICTORY!';
        message = 'You have defeated your enemies!';
        color = AppColors.green;
        coinsEarned = battleManager.calculateCoinsReward();
        _saveVictoryProgress();
        break;
      case BattleResult.defeat:
        title = 'DEFEAT';
        message = 'Your team has been defeated...';
        color = Colors.red;
        break;
      case BattleResult.draw:
        title = 'DRAW';
        message = 'Both teams were defeated!';
        color = Colors.orange;
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              result == BattleResult.victory
                  ? Icons.emoji_events
                  : result == BattleResult.defeat
                  ? Icons.close
                  : Icons.remove,
              color: color,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (coinsEarned > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+$coinsEarned coins',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha o dialog
              Navigator.of(context).pop(); // Volta para a tela anterior
            },
            child: const Text(
              'CONTINUE',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVictoryProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // Salvar moedas ganhas
    int currentCoins = prefs.getInt('coins') ?? 0;
    int coinsEarned = battleManager.calculateCoinsReward();
    await prefs.setInt('coins', currentCoins + coinsEarned);

    // Se for campanha, atualizar progresso
    if (widget.isCampaign && widget.campaignLevel != null) {
      int maxLevel = prefs.getInt('maxCampaignLevel') ?? 1;
      int currentLevel = prefs.getInt('campaignLevel') ?? 1;

      // Atualizar o nível atual da campanha se completou um nível superior
      if (widget.campaignLevel! > currentLevel) {
        await prefs.setInt('campaignLevel', widget.campaignLevel!);
      }

      // Se completou um nível novo ou igual ao máximo, desbloqueia o próximo
      if (widget.campaignLevel! >= maxLevel) {
        int newMaxLevel = widget.campaignLevel! + 1;
        await prefs.setInt('maxCampaignLevel', newMaxLevel);

        // Mostrar notificação de novo nível desbloqueado
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Campaign Level $newMaxLevel unlocked!'),
              backgroundColor: AppColors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Exit Battle?',
          style: TextStyle(color: AppColors.primary),
        ),
        content: const Text(
          'Are you sure you want to exit the battle? Progress will be lost.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha dialog
              Navigator.pop(context); // Sai da batalha
            },
            child: const Text('EXIT', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
