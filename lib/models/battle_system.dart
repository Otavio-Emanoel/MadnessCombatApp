import '../models/characters.dart';

// Enumerações para o sistema de batalha
enum BattlePhase {
  preparation, // Selecionando personagens e ações
  action, // Executando ações
  result, // Mostrando resultado
}

enum ActionType { attack, specialAbility, defend, useItem }

enum BattleResult { victory, defeat, draw }

// Classe para representar uma ação de batalha
class BattleAction {
  final BattleCharacter user;
  final ActionType type;
  final BattleCharacter? target;
  final String? abilityName;
  final int priority;

  BattleAction({
    required this.user,
    required this.type,
    this.target,
    this.abilityName,
    this.priority = 0,
  });
}

// Classe para representar o estado de um personagem em batalha
class BattleCharacter {
  final Characters character;
  int currentHealth;
  int currentMana;
  Map<String, int> cooldowns;
  List<String> activeEffects;
  bool isDefending;
  bool isKnockedOut;

  BattleCharacter({
    required this.character,
    int? startingHealth,
    int? startingMana,
  }) : currentHealth = startingHealth ?? character.health,
       currentMana = startingMana ?? 100,
       cooldowns = {},
       activeEffects = [],
       isDefending = false,
       isKnockedOut = false;

  // Calcula o poder total considerando bônus
  int get totalPower {
    int basePower = int.parse(character.power);
    // Adicionar bônus de efeitos ativos aqui se necessário
    return basePower;
  }

  // Calcula a defesa total considerando bônus
  int get totalDefense {
    int baseDefense = int.parse(character.defense);
    if (isDefending) baseDefense = (baseDefense * 1.5).round();
    return baseDefense;
  }

  // Calcula a velocidade total considerando bônus
  int get totalSpeed {
    return int.parse(character.speed);
  }

  // Verifica se pode usar uma habilidade
  bool canUseAbility(String abilityName) {
    if (isKnockedOut) return false;
    return (cooldowns[abilityName] ?? 0) <= 0;
  }

  // Aplica dano
  void takeDamage(int damage) {
    currentHealth = (currentHealth - damage).clamp(0, character.health);
    if (currentHealth <= 0) {
      isKnockedOut = true;
    }
  }

  // Cura
  void heal(int amount) {
    currentHealth = (currentHealth + amount).clamp(0, character.health);
    if (currentHealth > 0) {
      isKnockedOut = false;
    }
  }

  // Reduz cooldowns no final do turno
  void reduceCooldowns() {
    cooldowns.updateAll((key, value) => (value - 1).clamp(0, 999));
    isDefending = false;
  }

  // Adiciona cooldown para uma habilidade (em turnos)
  void addCooldown(String abilityName, int turns) {
    cooldowns[abilityName] = turns;
  }

  // Versão que aceita segundos e converte para turnos (melhorada)
  void addCooldownFromSeconds(String abilityName, int seconds) {
    // Aproximadamente 15-20 segundos por turno para um ritmo mais rápido
    int turns = (seconds / 18).ceil().clamp(
      1,
      10,
    ); // Limitado entre 1 e 10 turnos
    cooldowns[abilityName] = turns;
  }
}

// Classe para gerenciar uma equipe
class BattleTeam {
  final List<BattleCharacter> characters;
  final String teamName;
  final bool isPlayerTeam;

  BattleTeam({
    required this.characters,
    required this.teamName,
    this.isPlayerTeam = false,
  });

  List<BattleCharacter> get aliveCharacters {
    return characters.where((c) => !c.isKnockedOut).toList();
  }

  List<BattleCharacter> get knockedOutCharacters {
    return characters.where((c) => c.isKnockedOut).toList();
  }

  bool get isDefeated => aliveCharacters.isEmpty;

  int get totalPower {
    return aliveCharacters.fold(0, (sum, char) => sum + char.totalPower);
  }
}

// Classe principal para gerenciar a batalha
class BattleManager {
  BattleTeam playerTeam;
  BattleTeam enemyTeam;
  BattlePhase currentPhase;
  int currentTurn;
  List<BattleAction> pendingActions;
  List<String> battleLog;

  BattleManager({required this.playerTeam, required this.enemyTeam})
    : currentPhase = BattlePhase.preparation,
      currentTurn = 1,
      pendingActions = [],
      battleLog = [];

  // Inicia a batalha
  void startBattle() {
    currentPhase = BattlePhase.preparation;
    battleLog.add("Battle starts!");
    battleLog.add("${playerTeam.teamName} vs ${enemyTeam.teamName}");
  }

  // Adiciona uma ação à lista de ações pendentes
  void addAction(BattleAction action) {
    pendingActions.add(action);
  }

  // Executa todas as ações pendentes
  List<String> executeActions() {
    List<String> turnLog = [];
    currentPhase = BattlePhase.action;

    // Ordena ações por prioridade e velocidade
    pendingActions.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.compareTo(a.priority);
      }
      return b.user.totalSpeed.compareTo(a.user.totalSpeed);
    });

    // Executa cada ação
    for (var action in pendingActions) {
      if (!action.user.isKnockedOut) {
        var actionResult = _executeAction(action);
        turnLog.addAll(actionResult);
      }
    }

    // Reduz cooldowns e limpa ações
    _endTurn();
    pendingActions.clear();

    // Verifica condições de vitória
    _checkBattleEnd();

    battleLog.addAll(turnLog);
    return turnLog;
  }

  // Executa uma ação específica
  List<String> _executeAction(BattleAction action) {
    List<String> actionLog = [];

    switch (action.type) {
      case ActionType.attack:
        actionLog.addAll(_executeAttack(action.user, action.target!));
        break;
      case ActionType.specialAbility:
        actionLog.addAll(
          _executeSpecialAbility(
            action.user,
            action.target,
            action.abilityName!,
          ),
        );
        break;
      case ActionType.defend:
        actionLog.addAll(_executeDefend(action.user));
        break;
      case ActionType.useItem:
        // Implementar sistema de itens futuramente
        break;
    }

    return actionLog;
  }

  // Executa um ataque básico
  List<String> _executeAttack(
    BattleCharacter attacker,
    BattleCharacter target,
  ) {
    List<String> log = [];

    int damage = _calculateDamage(attacker.totalPower, target.totalDefense);
    target.takeDamage(damage);

    log.add(
      "${attacker.character.name} attacks ${target.character.name} for $damage damage!",
    );

    if (target.isKnockedOut) {
      log.add("${target.character.name} is knocked out!");
    }

    return log;
  }

  // Executa uma habilidade especial
  List<String> _executeSpecialAbility(
    BattleCharacter user,
    BattleCharacter? target,
    String abilityName,
  ) {
    List<String> log = [];

    if (!user.canUseAbility(abilityName)) {
      log.add("${user.character.name} cannot use $abilityName (cooling down)!");
      return log;
    }

    // Implementar habilidades específicas baseadas no personagem
    if (abilityName == user.character.specialAbility) {
      log.addAll(_executeCharacterSpecialAbility(user, target));
    }

    return log;
  }

  // Executa a habilidade especial específica do personagem (melhorado)
  List<String> _executeCharacterSpecialAbility(
    BattleCharacter user,
    BattleCharacter? target,
  ) {
    List<String> log = [];
    String abilityName = user.character.specialAbility;

    log.add("${user.character.name} uses $abilityName!");

    // Adiciona cooldown baseado nos segundos da habilidade
    user.addCooldownFromSeconds(
      abilityName,
      user.character.specialAbilityCooldown,
    );

    switch (abilityName.toLowerCase()) {
      case 'resurrection':
        if (user.currentHealth <= user.character.health * 0.4) {
          int healAmount = (user.character.health * 0.4).round();
          user.heal(healAmount);
          user.activeEffects.add('resurrection_boost_8');
          log.add(
            "${user.character.name} resurrects with $healAmount HP and feels empowered!",
          );
        } else {
          int healAmount = (user.character.health * 0.2).round();
          user.heal(healAmount);
          log.add(
            "${user.character.name} feels divine power healing for $healAmount HP!",
          );
        }
        break;

      case 'demon mode':
        user.activeEffects.add('demon_mode_20');
        log.add(
          "${user.character.name} transforms! Attack +30%, Defense -10%!",
        );
        // Efeito imediato: pequeno dano a todos os inimigos
        var enemies =
            user.character.type == playerTeam.characters.first.character.type
            ? enemyTeam.aliveCharacters
            : playerTeam.aliveCharacters;
        for (var enemy in enemies) {
          int demonDamage = 15;
          enemy.takeDamage(demonDamage);
          log.add("${enemy.character.name} takes $demonDamage demonic damage!");
          if (enemy.isKnockedOut) {
            log.add(
              "${enemy.character.name} is knocked out by the demonic aura!",
            );
          }
        }
        break;

      case 'master hacking':
        if (target != null) {
          target.activeEffects.add('hacked_15');
          int damage = user.character.specialAbilityDamage;
          target.takeDamage(damage);
          // Efeito adicional: reduz defesa do alvo
          target.activeEffects.add('defense_reduced_10');
          log.add(
            "${target.character.name} is hacked! Takes $damage damage and loses defense!",
          );
          if (target.isKnockedOut) {
            log.add("${target.character.name}'s systems shut down!");
          }
        }
        break;

      case 'chain attack':
        if (target != null) {
          int damage = _calculateDamage(
            user.totalPower + user.character.specialAbilityDamage,
            target.totalDefense,
          );
          target.takeDamage(damage);
          log.add("${target.character.name} takes $damage chain damage!");

          // Procurar outros inimigos próximos para atingir
          var enemies =
              target.character.type ==
                  playerTeam.characters.first.character.type
              ? enemyTeam.aliveCharacters
              : playerTeam.aliveCharacters;

          var otherEnemies = enemies.where((e) => e != target).take(2).toList();
          for (var enemy in otherEnemies) {
            int chainDamage = (damage * 0.7)
                .round(); // Aumentado de 60% para 70%
            enemy.takeDamage(chainDamage);
            log.add(
              "Chain hits ${enemy.character.name} for $chainDamage damage!",
            );
            if (enemy.isKnockedOut) {
              log.add("${enemy.character.name} is knocked out by the chain!");
            }
          }

          if (target.isKnockedOut) {
            log.add("${target.character.name} is knocked out!");
          }
        }
        break;

      case 'rage mode':
        user.activeEffects.add('rage_mode_15');
        // Efeito imediato: cura parcial
        int rageHeal = (user.character.health * 0.15).round();
        user.heal(rageHeal);
        log.add(
          "${user.character.name} enters RAGE MODE! Attack +35%, heals $rageHeal HP!",
        );
        break;

      case 'speed boost':
        user.activeEffects.add('speed_boost_12');
        // Permite ação dupla no próximo turno
        user.activeEffects.add('double_action_1');
        log.add(
          "${user.character.name} gains incredible speed and gets an extra action next turn!",
        );
        break;

      case 'improbability drive':
        // Efeito aleatório poderoso
        var effects = [
          'massive_damage',
          'full_heal',
          'enemy_confusion',
          'power_boost',
        ];
        var randomEffect =
            effects[DateTime.now().millisecondsSinceEpoch % effects.length];

        switch (randomEffect) {
          case 'massive_damage':
            if (target != null) {
              int damage = (user.totalPower * 2.5).round();
              target.takeDamage(damage);
              log.add(
                "Reality breaks! ${target.character.name} takes $damage impossible damage!",
              );
            }
            break;
          case 'full_heal':
            user.currentHealth = user.character.health;
            log.add(
              "The improbable happens! ${user.character.name} is fully healed!",
            );
            break;
          case 'enemy_confusion':
            var enemies =
                user.character.type ==
                    playerTeam.characters.first.character.type
                ? enemyTeam.aliveCharacters
                : playerTeam.aliveCharacters;
            for (var enemy in enemies) {
              enemy.activeEffects.add('confused_8');
            }
            log.add("Reality shifts! All enemies become confused!");
            break;
          case 'power_boost':
            user.activeEffects.add('improbable_power_20');
            log.add(
              "${user.character.name} gains improbable power! All stats boosted!",
            );
            break;
        }
        break;

      default:
        // Habilidade genérica melhorada
        if (target != null) {
          int baseDamage = user.character.specialAbilityDamage > 0
              ? user.character.specialAbilityDamage
              : (user.totalPower * 1.8).round(); // Aumentado multiplicador

          int damage = _calculateDamage(
            user.totalPower + baseDamage,
            target.totalDefense,
          );
          target.takeDamage(damage);
          log.add("${target.character.name} takes $damage special damage!");

          // 30% chance de efeito adicional aleatório
          if (DateTime.now().millisecondsSinceEpoch % 10 < 3) {
            var bonusEffects = ['stun_2', 'burn_5', 'weakness_6'];
            var effect =
                bonusEffects[DateTime.now().millisecondsSinceEpoch %
                    bonusEffects.length];
            target.activeEffects.add(effect);
            log.add(
              "${target.character.name} suffers from ${effect.split('_')[0]}!",
            );
          }

          if (target.isKnockedOut) {
            log.add("${target.character.name} is knocked out!");
          }
        } else {
          // Habilidades de buff/self-targeting melhoradas
          user.activeEffects.add('empowered_12');
          int healAmount = (user.character.health * 0.2).round();
          user.heal(healAmount);
          log.add(
            "${user.character.name} feels empowered and heals $healAmount HP!",
          );
        }
    }

    return log;
  }

  // Executa defesa
  List<String> _executeDefend(BattleCharacter defender) {
    defender.isDefending = true;
    return ["${defender.character.name} takes a defensive stance!"];
  }

  // Calcula dano baseado em poder e defesa
  int _calculateDamage(int power, int defense) {
    double baseDamage = power * 0.8;
    double damageReduction = defense * 0.3;
    int finalDamage = (baseDamage - damageReduction).round().clamp(1, 999);
    return finalDamage;
  }

  // Finaliza o turno
  void _endTurn() {
    currentTurn++;

    // Reduz cooldowns e efeitos
    for (var char in [...playerTeam.characters, ...enemyTeam.characters]) {
      char.reduceCooldowns();
      _processActiveEffects(char);
    }

    currentPhase = BattlePhase.preparation;
  }

  // Processa efeitos ativos
  void _processActiveEffects(BattleCharacter character) {
    character.activeEffects.removeWhere((effect) {
      List<String> parts = effect.split('_');
      if (parts.length >= 2) {
        int duration = int.tryParse(parts.last) ?? 0;
        duration--;
        if (duration <= 0) return true;

        // Atualiza duração
        parts[parts.length - 1] = duration.toString();
        effect = parts.join('_');
      }
      return false;
    });
  }

  // Verifica se a batalha terminou
  void _checkBattleEnd() {
    if (playerTeam.isDefeated) {
      currentPhase = BattlePhase.result;
      battleLog.add("Player team defeated!");
    } else if (enemyTeam.isDefeated) {
      currentPhase = BattlePhase.result;
      battleLog.add("Enemy team defeated! Victory!");
    }
  }

  // Retorna o resultado da batalha
  BattleResult? getBattleResult() {
    if (currentPhase != BattlePhase.result) return null;

    if (playerTeam.isDefeated && enemyTeam.isDefeated) {
      return BattleResult.draw;
    } else if (playerTeam.isDefeated) {
      return BattleResult.defeat;
    } else if (enemyTeam.isDefeated) {
      return BattleResult.victory;
    }

    return null;
  }

  // Calcula recompensas baseadas na dificuldade do inimigo (melhorado)
  int calculateCoinsReward() {
    if (getBattleResult() != BattleResult.victory) return 0;

    int baseCoinReward = 60; // Recompensa base aumentada
    int enemyPowerBonus = (enemyTeam.totalPower / 12)
        .round(); // Bônus por poder
    int turnBonus = (30 - currentTurn).clamp(0, 25); // Bônus por vitória rápida

    // Bônus por raridade dos inimigos (melhorado)
    int rarityBonus = 0;
    for (var enemy in enemyTeam.characters) {
      switch (enemy.character.rarity.toLowerCase()) {
        case 'legendary':
          rarityBonus += 50; // Aumentado
          break;
        case 'epic':
          rarityBonus += 35; // Aumentado
          break;
        case 'rare':
          rarityBonus += 20; // Aumentado
          break;
        case 'uncommon':
          rarityBonus += 10; // Aumentado
          break;
        default:
          rarityBonus += 5; // Aumentado
      }
    }

    int totalReward =
        baseCoinReward + enemyPowerBonus + turnBonus + rarityBonus;

    // Garantir recompensa mínima decente
    return totalReward.clamp(50, 300);
  }

  // Gera equipe inimiga balanceada (melhorado)
  static BattleTeam generateBalancedEnemyTeam(
    List<Characters> playerChars,
    List<Characters> availableEnemies,
  ) {
    int playerPower = playerChars.fold(
      0,
      (sum, char) => sum + int.parse(char.power),
    );

    // Calcular poder médio dos personagens do jogador
    double avgPlayerPower = playerPower / playerChars.length;

    List<Characters> selectedEnemies = [];

    // Filtrar inimigos com poder similar (±25% do poder médio do jogador)
    List<Characters> suitableEnemies = availableEnemies.where((enemy) {
      int enemyPower = int.parse(enemy.power);
      return enemyPower >= (avgPlayerPower * 0.75) &&
          enemyPower <= (avgPlayerPower * 1.25);
    }).toList();

    // Se não encontrou inimigos adequados, expandir critério
    if (suitableEnemies.length < 3) {
      suitableEnemies = availableEnemies.where((enemy) {
        int enemyPower = int.parse(enemy.power);
        return enemyPower >= (avgPlayerPower * 0.6) &&
            enemyPower <= (avgPlayerPower * 1.4);
      }).toList();
    }

    // Se ainda não tem suficientes, usar todos
    if (suitableEnemies.length < 3) {
      suitableEnemies = availableEnemies.toList();
    }

    // Embaralhar e selecionar 3 inimigos
    suitableEnemies.shuffle();
    selectedEnemies = suitableEnemies.take(3).toList();

    // Se ainda não tem 3, completar com inimigos aleatórios
    while (selectedEnemies.length < 3 && availableEnemies.isNotEmpty) {
      var randomEnemy =
          availableEnemies[DateTime.now().millisecondsSinceEpoch %
              availableEnemies.length];
      if (!selectedEnemies.contains(randomEnemy)) {
        selectedEnemies.add(randomEnemy);
      }
    }

    // Garantir que pelo menos temos alguns inimigos
    if (selectedEnemies.isEmpty && availableEnemies.isNotEmpty) {
      selectedEnemies.add(availableEnemies.first);
    }

    List<BattleCharacter> battleChars = selectedEnemies
        .map((char) => BattleCharacter(character: char))
        .toList();

    return BattleTeam(
      characters: battleChars,
      teamName: "Enemy Team",
      isPlayerTeam: false,
    );
  }

  // ===== SISTEMA DE IA INIMIGA MELHORADO =====

  // Executa o turno dos inimigos com IA estratégica
  List<String> executeEnemyTurn() {
    List<String> turnLog = [];
    turnLog.add("--- Enemy Turn ---");

    for (var enemy in enemyTeam.aliveCharacters) {
      if (enemy.isKnockedOut) continue;

      var aiAction = _determineEnemyAction(enemy);
      if (aiAction != null) {
        pendingActions.add(aiAction);
        turnLog.add(
          "${enemy.character.name} prepares to ${_getActionDescription(aiAction)}",
        );
      }
    }

    return turnLog;
  }

  // Determina a melhor ação para um inimigo baseado em IA estratégica
  BattleAction? _determineEnemyAction(BattleCharacter enemy) {
    var strategy = _analyzeStrategy(enemy);

    switch (strategy.type) {
      case AIStrategyType.aggressive:
        return _createAggressiveAction(enemy, strategy);
      case AIStrategyType.defensive:
        return _createDefensiveAction(enemy, strategy);
      case AIStrategyType.support:
        return _createSupportAction(enemy, strategy);
      case AIStrategyType.opportunistic:
        return _createOpportunisticAction(enemy, strategy);
    }

    // Fallback - ataque básico
    return BattleAction(
      user: enemy,
      type: ActionType.attack,
      target: _findBestTarget(enemy),
    );
  }

  // Analisa a situação e determina a estratégia da IA
  AIStrategy _analyzeStrategy(BattleCharacter enemy) {
    var aliveEnemies = enemyTeam.aliveCharacters.length;
    var alivePlayers = playerTeam.aliveCharacters.length;
    var enemyHealthPercent = enemy.currentHealth / enemy.character.health;
    var teamHealthPercent = _getTeamHealthPercent(enemyTeam);

    var weakestPlayer = _findWeakestTarget(playerTeam.aliveCharacters);
    var strongestPlayer = _findStrongestTarget(playerTeam.aliveCharacters);

    // Fatores de decisão
    bool isLowHealth = enemyHealthPercent < 0.3;
    bool teamIsLosing = aliveEnemies < alivePlayers;
    bool hasSpecialAbility = enemy.canUseAbility(
      enemy.character.specialAbility,
    );
    bool canFinishTarget =
        weakestPlayer != null &&
        _calculateDamage(enemy.totalPower, weakestPlayer.totalDefense) >=
            weakestPlayer.currentHealth;

    // Determinar tipo de estratégia
    AIStrategyType strategyType;
    BattleCharacter? primaryTarget;
    int priority = 0;

    if (canFinishTarget) {
      // Prioridade máxima: finalizar um inimigo
      strategyType = AIStrategyType.opportunistic;
      primaryTarget = weakestPlayer;
      priority = 100;
    } else if (isLowHealth && teamHealthPercent < 0.5) {
      // Estratégia defensiva quando em perigo
      strategyType = AIStrategyType.defensive;
      priority = 80;
    } else if (hasSpecialAbility && strongestPlayer != null) {
      // Usar habilidade especial contra o mais forte
      strategyType = AIStrategyType.aggressive;
      primaryTarget = strongestPlayer;
      priority = 90;
    } else if (teamIsLosing) {
      // Estratégia agressiva quando perdendo
      strategyType = AIStrategyType.aggressive;
      primaryTarget = strongestPlayer ?? weakestPlayer;
      priority = 70;
    } else {
      // Estratégia padrão: atacar o mais fraco
      strategyType = AIStrategyType.aggressive;
      primaryTarget = weakestPlayer;
      priority = 60;
    }

    return AIStrategy(
      type: strategyType,
      primaryTarget: primaryTarget,
      priority: priority,
      reasoningFactors: {
        'health_percent': enemyHealthPercent,
        'team_health': teamHealthPercent,
        'can_finish': canFinishTarget,
        'has_special': hasSpecialAbility,
        'team_losing': teamIsLosing,
      },
    );
  }

  // Cria ação agressiva
  BattleAction? _createAggressiveAction(
    BattleCharacter enemy,
    AIStrategy strategy,
  ) {
    // 60% chance de usar habilidade especial se disponível
    if (enemy.canUseAbility(enemy.character.specialAbility) &&
        DateTime.now().millisecondsSinceEpoch % 10 < 6) {
      return BattleAction(
        user: enemy,
        type: ActionType.specialAbility,
        target: strategy.primaryTarget ?? _findBestTarget(enemy),
        abilityName: enemy.character.specialAbility,
      );
    }

    // Ataque básico
    return BattleAction(
      user: enemy,
      type: ActionType.attack,
      target: strategy.primaryTarget ?? _findBestTarget(enemy),
    );
  }

  // Cria ação defensiva
  BattleAction? _createDefensiveAction(
    BattleCharacter enemy,
    AIStrategy strategy,
  ) {
    var healthPercent = enemy.currentHealth / enemy.character.health;

    // Se estiver muito ferido, usar habilidade de cura/buff se disponível
    if (healthPercent < 0.4 &&
        enemy.canUseAbility(enemy.character.specialAbility)) {
      var abilityName = enemy.character.specialAbility.toLowerCase();
      if (abilityName.contains('heal') ||
          abilityName.contains('resurrect') ||
          abilityName.contains('defense') ||
          abilityName.contains('protection')) {
        return BattleAction(
          user: enemy,
          type: ActionType.specialAbility,
          target: null, // Self-target
          abilityName: enemy.character.specialAbility,
        );
      }
    }

    // 70% chance de defender, 30% de atacar conservadoramente
    if (DateTime.now().millisecondsSinceEpoch % 10 < 7) {
      return BattleAction(user: enemy, type: ActionType.defend);
    } else {
      return BattleAction(
        user: enemy,
        type: ActionType.attack,
        target: _findWeakestTarget(playerTeam.aliveCharacters),
      );
    }
  }

  // Cria ação de suporte
  BattleAction? _createSupportAction(
    BattleCharacter enemy,
    AIStrategy strategy,
  ) {
    // Procurar aliados que precisam de ajuda
    var woundedAlly = _findMostWoundedAlly(enemy);

    if (woundedAlly != null &&
        enemy.canUseAbility(enemy.character.specialAbility)) {
      var abilityName = enemy.character.specialAbility.toLowerCase();
      if (abilityName.contains('heal') ||
          abilityName.contains('boost') ||
          abilityName.contains('support')) {
        return BattleAction(
          user: enemy,
          type: ActionType.specialAbility,
          target: woundedAlly,
          abilityName: enemy.character.specialAbility,
        );
      }
    }

    // Se não pode ajudar, atacar
    return _createAggressiveAction(enemy, strategy);
  }

  // Cria ação oportunística (finishing moves)
  BattleAction? _createOpportunisticAction(
    BattleCharacter enemy,
    AIStrategy strategy,
  ) {
    var target = strategy.primaryTarget;

    if (target != null) {
      // Sempre usar habilidade especial para finalizar se disponível
      if (enemy.canUseAbility(enemy.character.specialAbility)) {
        return BattleAction(
          user: enemy,
          type: ActionType.specialAbility,
          target: target,
          abilityName: enemy.character.specialAbility,
        );
      }

      // Ataque normal para finalizar
      return BattleAction(user: enemy, type: ActionType.attack, target: target);
    }

    // Fallback para estratégia agressiva
    return _createAggressiveAction(enemy, strategy);
  }

  // Encontra o melhor alvo baseado em múltiplos fatores
  BattleCharacter? _findBestTarget(BattleCharacter attacker) {
    var targets = playerTeam.aliveCharacters;
    if (targets.isEmpty) return null;

    // Calcular score para cada alvo
    BattleCharacter? bestTarget;
    double bestScore = -1;

    for (var target in targets) {
      double score = _calculateTargetPriority(attacker, target);
      if (score > bestScore) {
        bestScore = score;
        bestTarget = target;
      }
    }

    return bestTarget;
  }

  // Calcula prioridade de alvo baseado em múltiplos fatores
  double _calculateTargetPriority(
    BattleCharacter attacker,
    BattleCharacter target,
  ) {
    double score = 0;

    // Fator de vida (alvos com menos vida têm prioridade)
    double healthPercent = target.currentHealth / target.character.health;
    score += (1.0 - healthPercent) * 40; // 0-40 pontos

    // Fator de ameaça (alvos mais fortes têm mais prioridade)
    double threatLevel = (target.totalPower + target.totalSpeed) / 200.0;
    score += threatLevel * 30; // 0-30 pontos

    // Fator de facilidade de kill (dano que pode causar vs vida do alvo)
    int potentialDamage = _calculateDamage(
      attacker.totalPower,
      target.totalDefense,
    );
    if (potentialDamage >= target.currentHealth) {
      score += 50; // Bônus por poder finalizar
    }

    // Fator de tipo (certas classes têm prioridade)
    switch (target.character.type.toLowerCase()) {
      case 'support':
        score += 25; // Prioridade em suporte
        break;
      case 'ally':
        score += 20; // Alta prioridade
        break;
      case 'protagonist':
        score += 30; // Máxima prioridade
        break;
    }

    // Fator de raridade (personagens lendários são prioridade)
    switch (target.character.rarity.toLowerCase()) {
      case 'legendary':
        score += 20;
        break;
      case 'epic':
        score += 15;
        break;
      case 'rare':
        score += 10;
        break;
    }

    return score;
  }

  // Utilitários para IA
  BattleCharacter? _findWeakestTarget(List<BattleCharacter> targets) {
    if (targets.isEmpty) return null;
    return targets.reduce((a, b) => a.currentHealth < b.currentHealth ? a : b);
  }

  BattleCharacter? _findStrongestTarget(List<BattleCharacter> targets) {
    if (targets.isEmpty) return null;
    return targets.reduce((a, b) => a.totalPower > b.totalPower ? a : b);
  }

  BattleCharacter? _findMostWoundedAlly(BattleCharacter excludeSelf) {
    var allies = enemyTeam.aliveCharacters
        .where((c) => c != excludeSelf)
        .toList();
    if (allies.isEmpty) return null;

    return allies.reduce((a, b) {
      double aHealthPercent = a.currentHealth / a.character.health;
      double bHealthPercent = b.currentHealth / b.character.health;
      return aHealthPercent < bHealthPercent ? a : b;
    });
  }

  double _getTeamHealthPercent(BattleTeam team) {
    if (team.characters.isEmpty) return 0;

    double totalCurrentHealth = team.characters.fold(
      0,
      (sum, char) => sum + char.currentHealth,
    );
    double totalMaxHealth = team.characters.fold(
      0,
      (sum, char) => sum + char.character.health,
    );

    return totalCurrentHealth / totalMaxHealth;
  }

  String _getActionDescription(BattleAction action) {
    switch (action.type) {
      case ActionType.attack:
        return "attack ${action.target?.character.name ?? 'target'}";
      case ActionType.specialAbility:
        return "use ${action.abilityName}";
      case ActionType.defend:
        return "defend";
      case ActionType.useItem:
        return "use item";
    }
  }
}

// Enum para tipos de estratégia da IA
enum AIStrategyType {
  aggressive, // Foco em atacar e causar dano
  defensive, // Foco em defender e sobreviver
  support, // Foco em ajudar aliados
  opportunistic, // Foco em finalizar inimigos feridos
}

// Classe para representar uma estratégia da IA
class AIStrategy {
  final AIStrategyType type;
  final BattleCharacter? primaryTarget;
  final int priority;
  final Map<String, dynamic> reasoningFactors;

  AIStrategy({
    required this.type,
    this.primaryTarget,
    required this.priority,
    required this.reasoningFactors,
  });
}
