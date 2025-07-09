class Characters {
  String name;
  String image;
  String description;
  String rarity;
  String type;
  String power;
  String defense;
  String speed;
  String specialAbility;
  String specialAbilityDescription; // Descrição da habilidade especial
  int
  specialAbilityDamage; // Dano da habilidade especial (porcentagem ou valor fixo)
  int specialAbilityCooldown; // Tempo de recarga da habilidade em segundos
  int health; // Pontos de vida base do personagem
  String level;
  // Novas propriedades para habilidades desbloqueáveis
  List<UnlockableAbility> unlockableAbilities;

  Characters({
    required this.name,
    required this.image,
    required this.description,
    required this.rarity,
    required this.type,
    required this.power,
    required this.defense,
    required this.speed,
    required this.specialAbility,
    this.specialAbilityDescription = '', // Valor padrão
    this.specialAbilityDamage = 0, // Valor padrão
    this.specialAbilityCooldown = 0, // Valor padrão
    this.health = 100, // Valor padrão
    required this.level,
    this.unlockableAbilities = const [],
  });
}

// Classe para representar habilidades desbloqueáveis
class UnlockableAbility {
  final String name;
  final String description;
  final int levelRequired;
  final String icon; // Ícone da habilidade
  final int damageBonus; // Dano adicional em porcentagem ou valor fixo
  final int cooldown; // Tempo de recarga em segundos
  final String
  effectType; // Tipo de efeito: "damage", "heal", "buff", "debuff", "special"
  final int effectDuration; // Duração do efeito em segundos, se aplicável

  const UnlockableAbility({
    required this.name,
    required this.description,
    required this.levelRequired,
    this.icon = 'bolt', // Ícone padrão
    this.damageBonus = 0,
    this.cooldown = 0,
    this.effectType = 'damage',
    this.effectDuration = 0,
  });
}

// Lista de personagens do universo Madness Combat
final List<Characters> madnessCharacters = [];

// Lista estática de personagens reais de Madness Combat
final List<Characters> allCharacters = [
  // Personagens Lendários (com "L" no nome do arquivo)
  Characters(
    name: 'Hank J. Wimbleton',
    image: 'assets/images/characters/hankL.png',
    description:
        'The main protagonist of the Madness Combat series. A relentless fighter known for his resilience and exceptional combat skills.',
    rarity: 'Legendary',
    type: 'Protagonist',
    power: '95',
    defense: '90',
    speed: '85',
    specialAbility: 'Resurrection',
    specialAbilityDescription:
        'Revives with 30% health when killed, can occur once per battle',
    specialAbilityDamage: 0,
    specialAbilityCooldown: 180, // 3 minutos de cooldown
    health: 150, // Vida mais alta por ser lendário
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Berserker',
        description: 'Increases attack power by 25% when health is below 30%',
        levelRequired: 3,
        icon: 'local_fire_department',
        damageBonus: 25, // 25% de bônus de dano
        effectType: 'buff',
        effectDuration: 15, // 15 segundos de duração
      ),
      UnlockableAbility(
        name: 'Tactical Mastery',
        description:
            'Can use any weapon with maximum proficiency, increasing damage by 15%',
        levelRequired: 5,
        icon: 'sports_martial_arts',
        damageBonus: 15, // 15% de bônus de dano
        effectType: 'buff',
        effectDuration: 0, // Passivo permanente
      ),
      UnlockableAbility(
        name: 'Death-Defying',
        description:
            'Once per battle, survives a fatal blow with 10% health and gains 30% speed for 10 seconds',
        levelRequired: 10,
        icon: 'health_and_safety',
        damageBonus: 0,
        cooldown: 300, // 5 minutos de cooldown
        effectType: 'special',
        effectDuration: 10, // 10 segundos de buff de velocidade após sobreviver
      ),
    ],
  ),
  Characters(
    name: 'Tricky the Clown',
    image: 'assets/images/characters/trickyL.png',
    description:
        'The insane clown and recurring antagonist. Possesses supernatural powers and is highly unpredictable.',
    rarity: 'Legendary',
    type: 'Antagonist',
    power: '99',
    defense: '80',
    speed: '90',
    specialAbility: 'Demon Mode',
    specialAbilityDescription:
        'Transforms into a demonic form, increasing power by 50% for 20 seconds',
    specialAbilityDamage: 50, // 50% de aumento de dano
    specialAbilityCooldown: 120, // 2 minutos de cooldown
    health: 180, // Vida ainda mais alta por ser um dos mais poderosos
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Improbability Drive',
        description:
            'Has a 15% chance to ignore damage completely and counter-attack with 40% extra damage',
        levelRequired: 3,
        icon: 'crisis_alert',
        damageBonus: 40, // 40% de dano no contra-ataque
        effectType: 'special',
        effectDuration: 0, // Passivo permanente
      ),
      UnlockableAbility(
        name: 'Clown Rage',
        description:
            'Speed increases by 30% when taking damage and grants a 20% damage boost for 8 seconds',
        levelRequired: 5,
        icon: 'sentiment_very_dissatisfied',
        damageBonus: 20, // 20% de bônus de dano
        cooldown: 30, // 30 segundos de cooldown
        effectType: 'buff',
        effectDuration: 8, // 8 segundos de duração
      ),
      UnlockableAbility(
        name: 'Reality Warper',
        description:
            'Can transform the battlefield, disorienting enemies, reducing their accuracy by 25% and speed by 15%',
        levelRequired: 8,
        icon: 'rotate_90_degrees_ccw',
        damageBonus: 0,
        cooldown: 90, // 90 segundos de cooldown
        effectType: 'debuff',
        effectDuration: 12, // 12 segundos de duração
      ),
    ],
  ),
  Characters(
    name: 'Deimos (Legendary)',
    image: 'assets/images/characters/deimosL.png',
    description:
        'The legendary version of Deimos with enhanced abilities. Expert in technology and explosives with superior combat skills.',
    rarity: 'Legendary',
    type: 'Ally',
    power: '90',
    defense: '85',
    speed: '88',
    specialAbility: 'Master Hacking',
    specialAbilityDescription:
        'Hacks enemy systems, disabling their special abilities for 15 seconds and dealing tech damage',
    specialAbilityDamage: 60, // Dano da habilidade
    specialAbilityCooldown: 60, // 1 minuto de cooldown
    health: 140, // Vida base
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Explosive Expert',
        description:
            'Plants explosives that deal 70 damage to all enemies in area and stun them for 3 seconds',
        levelRequired: 3,
        icon: 'explore',
        damageBonus: 70, // Dano fixo
        cooldown: 45, // 45 segundos de cooldown
        effectType: 'damage',
        effectDuration: 3, // 3 segundos de stun
      ),
      UnlockableAbility(
        name: 'Tactical Support',
        description:
            'Calls in tactical support that boosts team damage by 20% and reduces incoming damage by 15% for 10 seconds',
        levelRequired: 6,
        icon: 'support',
        damageBonus: 20, // 20% de bônus de dano para o time
        cooldown: 90, // 90 segundos de cooldown
        effectType: 'buff',
        effectDuration: 10, // 10 segundos de duração
      ),
      UnlockableAbility(
        name: 'Stealth Operative',
        description:
            'Becomes invisible for 5 seconds, next attack after stealth deals 50% more damage and ignores defense',
        levelRequired: 9,
        icon: 'visibility_off',
        damageBonus: 50, // 50% de bônus de dano após stealth
        cooldown: 75, // 75 segundos de cooldown
        effectType: 'special',
        effectDuration: 5, // 5 segundos de invisibilidade
      ),
    ],
  ),
  Characters(
    name: 'Sanford (Legendary)',
    image: 'assets/images/characters/sanfordL.png',
    description:
        'The legendary version of Sanford with enhanced combat prowess. Master of melee combat and team tactics.',
    rarity: 'Legendary',
    type: 'Ally',
    power: '92',
    defense: '88',
    speed: '85',
    specialAbility: 'Ultimate Chain Attack',
    specialAbilityDescription:
        'Unleashes a devastating chain attack that hits up to 3 enemies, dealing damage to each',
    specialAbilityDamage: 80, // Dano total dividido entre os alvos
    specialAbilityCooldown: 45, // 45 segundos de cooldown
    health: 160, // Vida base alta por ser tank
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Hook Master',
        description:
            'Throws hook to pull an enemy, stunning them for 2 seconds and dealing 40 damage',
        levelRequired: 3,
        icon: 'sports_hockey',
        damageBonus: 40, // Dano fixo
        cooldown: 30, // 30 segundos de cooldown
        effectType: 'damage',
        effectDuration: 2, // 2 segundos de stun
      ),
      UnlockableAbility(
        name: 'Defensive Formation',
        description:
            'Creates a defensive formation that reduces damage taken by 30% for 8 seconds',
        levelRequired: 5,
        icon: 'security',
        damageBonus: 0,
        cooldown: 60, // 60 segundos de cooldown
        effectType: 'buff',
        effectDuration: 8, // 8 segundos de duração
      ),
      UnlockableAbility(
        name: 'Chain Specialist',
        description:
            'Passive: Normal attacks have 25% chance to hit an additional enemy for 40% of the damage',
        levelRequired: 8,
        icon: 'link',
        damageBonus: 40, // 40% do dano principal
        cooldown: 0,
        effectType: 'special',
        effectDuration: 0, // Passivo permanente
      ),
    ],
  ),

  // Personagens regulares
  Characters(
    name: 'Hank J. Wimbleton (Mag)',
    image: 'assets/images/characters/hankMag.png',
    description:
        'Hank in his magnified form. Enhanced with superior strength and durability, making him even more deadly.',
    rarity: 'Epic',
    type: 'Protagonist',
    power: '93',
    defense: '92',
    speed: '75',
    specialAbility: 'Mag Enhancement',
    specialAbilityDescription:
        'Enhanced physical prowess increases damage by 40% for 15 seconds',
    specialAbilityDamage: 40, // 40% de aumento de dano
    specialAbilityCooldown: 90, // 1,5 minutos de cooldown
    health: 170, // Vida mais alta devido à forma Mag
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Ground Slam',
        description:
            'Slams the ground, dealing 60 damage to all nearby enemies and knocking them back',
        levelRequired: 3,
        icon: 'golf_course',
        damageBonus: 60, // Dano fixo
        cooldown: 40, // 40 segundos de cooldown
        effectType: 'damage',
        effectDuration: 0,
      ),
      UnlockableAbility(
        name: 'Mag Armor',
        description: 'Passive: Reduces all incoming damage by 20%',
        levelRequired: 6,
        icon: 'shield',
        damageBonus: 0,
        cooldown: 0,
        effectType: 'buff',
        effectDuration: 0, // Passivo permanente
      ),
      UnlockableAbility(
        name: 'Unstoppable Force',
        description:
            'Becomes immune to stun and knockback effects for 6 seconds and gains 25% movement speed',
        levelRequired: 9,
        icon: 'flash_on',
        damageBonus: 0,
        cooldown: 70, // 70 segundos de cooldown
        effectType: 'buff',
        effectDuration: 6, // 6 segundos de duração
      ),
    ],
  ),
  Characters(
    name: 'Hank (Accelerant)',
    image: 'assets/images/characters/hankAccelerant.png',
    description:
        'Hank in his accelerant form, faster and more agile than his standard version.',
    rarity: 'Epic',
    type: 'Protagonist',
    power: '90',
    defense: '80',
    speed: '95',
    specialAbility: 'Speed Boost',
    specialAbilityDescription:
        'Increases movement speed by 50% and attack speed by 30% for 12 seconds',
    specialAbilityDamage: 0,
    specialAbilityCooldown: 60, // 1 minuto de cooldown
    health: 130, // Vida média por ser focado em velocidade
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Quick Strike',
        description:
            'Executes a series of rapid strikes, hitting 5 times for 15 damage each',
        levelRequired: 3,
        icon: 'speed',
        damageBonus: 75, // Dano total (15 x 5)
        cooldown: 25, // 25 segundos de cooldown
        effectType: 'damage',
        effectDuration: 0,
      ),
      UnlockableAbility(
        name: 'Accelerant Dash',
        description:
            'Dashes forward, becoming invulnerable for 2 seconds and increasing next attack damage by 35%',
        levelRequired: 5,
        icon: 'directions_run',
        damageBonus: 35, // 35% de bônus no próximo ataque
        cooldown: 30, // 30 segundos de cooldown
        effectType: 'special',
        effectDuration: 2, // 2 segundos de invulnerabilidade
      ),
      UnlockableAbility(
        name: 'Blitz Mode',
        description:
            'Enters Blitz Mode for 8 seconds, dodging 30% of all incoming attacks and increasing critical hit chance by 20%',
        levelRequired: 8,
        icon: 'flash_on',
        damageBonus: 0,
        cooldown: 80, // 80 segundos de cooldown
        effectType: 'buff',
        effectDuration: 8, // 8 segundos de duração
      ),
    ],
  ),
  Characters(
    name: 'Hank (Antipathy)',
    image: 'assets/images/characters/hankAntipathy.png',
    description:
        'Hank from the Antipathy episode, showing increased aggression and combat abilities.',
    rarity: 'Epic',
    type: 'Protagonist',
    power: '88',
    defense: '85',
    speed: '87',
    specialAbility: 'Rage Mode',
    specialAbilityDescription:
        'Enters a state of rage, increasing damage by 35% but reducing defense by 15% for 15 seconds',
    specialAbilityDamage: 35, // 35% de aumento de dano
    specialAbilityCooldown: 75, // 1.25 minutos de cooldown
    health: 140, // Vida média-alta
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Adrenaline Rush',
        description:
            'Gains 20% attack speed and 15% movement speed for 10 seconds when health drops below 40%',
        levelRequired: 3,
        icon: 'favorite',
        damageBonus: 0,
        cooldown: 90, // 90 segundos de cooldown
        effectType: 'buff',
        effectDuration: 10, // 10 segundos de duração
      ),
      UnlockableAbility(
        name: 'Brutal Strike',
        description:
            'Powerful strike that deals 60 damage and stuns the target for 3 seconds',
        levelRequired: 6,
        icon: 'gavel',
        damageBonus: 60, // Dano fixo
        cooldown: 45, // 45 segundos de cooldown
        effectType: 'damage',
        effectDuration: 3, // 3 segundos de stun
      ),
      UnlockableAbility(
        name: 'Antipathy',
        description:
            'Passive: Damage increases by 2% for each 5% of health missing',
        levelRequired: 9,
        icon: 'whatshot',
        damageBonus: 0, // Variável baseado na vida perdida
        cooldown: 0,
        effectType: 'buff',
        effectDuration: 0, // Passivo permanente
      ),
    ],
  ),
  Characters(
    name: 'Hank (Depredation)',
    image: 'assets/images/characters/hankDepredation.png',
    description:
        'Hank from the Depredation episode, adapting to new challenges with improved tactics.',
    rarity: 'Epic',
    type: 'Protagonist',
    power: '87',
    defense: '83',
    speed: '88',
    specialAbility: 'Tactical Adaptation',
    specialAbilityDescription:
        'Analyzes enemies and adapts tactics, increasing damage against them by 30% for 20 seconds',
    specialAbilityDamage: 30, // 30% de aumento de dano
    specialAbilityCooldown: 80, // 1.33 minutos de cooldown
    health: 135, // Vida média
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Adaptive Defense',
        description:
            'After taking damage, gains 25% resistance to that damage type for 12 seconds',
        levelRequired: 3,
        icon: 'auto_fix_high',
        damageBonus: 0,
        cooldown: 40, // 40 segundos de cooldown
        effectType: 'buff',
        effectDuration: 12, // 12 segundos de duração
      ),
      UnlockableAbility(
        name: 'Tactical Strike',
        description:
            'Targets enemy weak point, dealing 50 damage and reducing their attack speed by 20% for 5 seconds',
        levelRequired: 5,
        icon: 'adjust',
        damageBonus: 50, // Dano fixo
        cooldown: 35, // 35 segundos de cooldown
        effectType: 'damage',
        effectDuration: 5, // 5 segundos de debuff
      ),
      UnlockableAbility(
        name: 'Improvised Weapon',
        description:
            'Can use environmental objects as weapons, dealing 65 damage and knocking back enemies',
        levelRequired: 8,
        icon: 'handyman',
        damageBonus: 65, // Dano fixo
        cooldown: 50, // 50 segundos de cooldown
        effectType: 'special',
        effectDuration: 0,
      ),
    ],
  ),
  Characters(
    name: 'Hank (MC1)',
    image: 'assets/images/characters/hank1.png',
    description:
        'The original version of Hank from the first Madness Combat episode.',
    rarity: 'Rare',
    type: 'Protagonist',
    power: '80',
    defense: '75',
    speed: '80',
    specialAbility: 'Combat Basics',
    specialAbilityDescription:
        'Uses fundamental combat techniques to increase attack speed by 25% for 10 seconds',
    specialAbilityDamage: 0,
    specialAbilityCooldown: 50, // 50 segundos de cooldown
    health: 120, // Vida padrão
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Quick Reflexes',
        description: 'Has a 20% chance to dodge incoming attacks',
        levelRequired: 3,
        icon: 'autorenew',
        damageBonus: 0,
        cooldown: 0,
        effectType: 'buff',
        effectDuration: 0, // Passivo permanente
      ),
      UnlockableAbility(
        name: 'Disarm',
        description:
            'Disarms an enemy, preventing them from using weapons for a short time and dealing 40 damage',
        levelRequired: 5,
        icon: 'do_not_touch',
        damageBonus: 40, // Dano fixo
        cooldown: 40, // 40 segundos de cooldown
        effectType: 'debuff',
        effectDuration: 6, // 6 segundos de duração
      ),
      UnlockableAbility(
        name: 'Combat Experience',
        description:
            'Passive: Each successful hit increases damage by 5%, stacking up to 4 times (20% total)',
        levelRequired: 7,
        icon: 'trending_up',
        damageBonus: 5, // 5% por stack, até 20%
        cooldown: 0,
        effectType: 'buff',
        effectDuration: 8, // 8 segundos de duração dos stacks
      ),
    ],
  ),
  Characters(
    name: 'Tricky (Mad)',
    image: 'assets/images/characters/madTricky.png',
    description:
        'Tricky in his enraged form, showing increased aggression and unpredictability.',
    rarity: 'Epic',
    type: 'Antagonist',
    power: '93',
    defense: '78',
    speed: '92',
    specialAbility: 'Rage Boost',
    specialAbilityDescription:
        'Goes into a frenzy, increasing attack speed by 40% and movement by 30% for 15 seconds',
    specialAbilityDamage: 0,
    specialAbilityCooldown: 70, // 70 segundos de cooldown
    health: 150, // Vida alta
    level: '1',
    unlockableAbilities: [
      UnlockableAbility(
        name: 'Unpredictable',
        description:
            'Movements become erratic, reducing enemy accuracy by 25% when attacking you',
        levelRequired: 3,
        icon: 'shuffle',
        damageBonus: 0,
        cooldown: 0,
        effectType: 'debuff',
        effectDuration: 0, // Passivo permanente
      ),
      UnlockableAbility(
        name: 'Maniacal Laugh',
        description:
            'Terrifying laugh that frightens enemies, reducing their attack power by 20% for 8 seconds',
        levelRequired: 5,
        icon: 'mood_bad',
        damageBonus: 0,
        cooldown: 45, // 45 segundos de cooldown
        effectType: 'debuff',
        effectDuration: 8, // 8 segundos de duração
      ),
      UnlockableAbility(
        name: 'Chaotic Frenzy',
        description: 'Attacks randomly hit up to 3 enemies for 30 damage each',
        levelRequired: 8,
        icon: 'psychology',
        damageBonus: 90, // 30 x 3 dano total máximo
        cooldown: 60, // 60 segundos de cooldown
        effectType: 'damage',
        effectDuration: 0,
      ),
    ],
  ),
  Characters(
    name: 'Tricky (Mad V2)',
    image: 'assets/images/characters/madTricky2.png',
    description:
        'An alternative version of Mad Tricky with different attack patterns.',
    rarity: 'Epic',
    type: 'Antagonist',
    power: '94',
    defense: '79',
    speed: '91',
    specialAbility: 'Chaotic Strikes',
    level: '1',
  ),
  Characters(
    name: 'Tricky (Mad V3)',
    image: 'assets/images/characters/madTricky3.png',
    description:
        'The third variation of Mad Tricky, showcasing even more chaotic abilities.',
    rarity: 'Epic',
    type: 'Antagonist',
    power: '95',
    defense: '80',
    speed: '90',
    specialAbility: 'Ultimate Chaos',
    level: '1',
  ),
  Characters(
    name: 'Tricky (Expurgation)',
    image: 'assets/images/characters/expurgationTricky.png',
    description:
        'Tricky in his most powerful form from the Expurgation episode. Nearly unstoppable.',
    rarity: 'Epic',
    type: 'Antagonist',
    power: '98',
    defense: '85',
    speed: '94',
    specialAbility: 'Expurgation Mode',
    level: '1',
  ),
  Characters(
    name: 'Tricky (Mag Agent)',
    image: 'assets/images/characters/magAgentTricky.png',
    description:
        'Tricky as a Mag Agent, combining his chaotic nature with enhanced size and strength.',
    rarity: 'Epic',
    type: 'Antagonist',
    power: '96',
    defense: '88',
    speed: '75',
    specialAbility: 'Mag Chaos',
    level: '1',
  ),
  Characters(
    name: 'Tricky Agents',
    image: 'assets/images/characters/trickyAgents.png',
    description:
        'Agents under Tricky\'s influence, showing erratic behavior and increased aggression.',
    rarity: 'Rare',
    type: 'Minion',
    power: '70',
    defense: '65',
    speed: '75',
    specialAbility: 'Chaotic Loyalty',
    level: '1',
  ),
  Characters(
    name: 'Sanford',
    image: 'assets/images/characters/sanford.png',
    description:
        'Partner of Deimos, specialist in melee combat and team tactics.',
    rarity: 'Rare',
    type: 'Ally',
    power: '80',
    defense: '75',
    speed: '70',
    specialAbility: 'Chain Attack',
    level: '1',
  ),
  Characters(
    name: 'Deimos',
    image: 'assets/images/characters/deimos.png',
    description: 'Ally of Sanford, specialist in technology and explosives.',
    rarity: 'Rare',
    type: 'Ally',
    power: '78',
    defense: '70',
    speed: '75',
    specialAbility: 'Hacking',
    level: '1',
  ),
  Characters(
    name: 'Deimos (Stone)',
    image: 'assets/images/characters/deimosStone.png',
    description:
        'Deimos in his stone form, showing increased defense but reduced mobility.',
    rarity: 'Rare',
    type: 'Ally',
    power: '75',
    defense: '90',
    speed: '50',
    specialAbility: 'Stone Defense',
    level: '1',
  ),
  Characters(
    name: 'Jebus',
    image: 'assets/images/characters/jebus.png',
    description:
        'Powerful figure capable of manipulating weapons and resurrecting. Sometimes antagonist, sometimes ally.',
    rarity: 'Epic',
    type: 'Antagonist',
    power: '97',
    defense: '85',
    speed: '80',
    specialAbility: 'Resurrection',
    level: '1',
  ),
  Characters(
    name: 'Jebus (Mad)',
    image: 'assets/images/characters/jebusMad.png',
    description:
        'Jebus in his enraged form, showing increased power and aggression.',
    rarity: 'Epic',
    type: 'Antagonist',
    power: '98',
    defense: '87',
    speed: '82',
    specialAbility: 'Divine Wrath',
    level: '1',
  ),
  Characters(
    name: 'Auditor',
    image: 'assets/images/characters/auditor.png',
    description:
        'Leader of the A.A.H.W. and one of the most powerful villains, manipulates shadows and energy.',
    rarity: 'Epic',
    type: 'Villain',
    power: '100',
    defense: '95',
    speed: '70',
    specialAbility: 'Shadow Manipulation',
    level: '1',
  ),
  Characters(
    name: 'Grunt',
    image: 'assets/images/characters/grunt.png',
    description:
        'Standard soldier of the series, appears in large numbers as enemies.',
    rarity: 'Common',
    type: 'Enemy',
    power: '40',
    defense: '30',
    speed: '40',
    specialAbility: 'None',
    level: '1',
  ),
  Characters(
    name: 'Grunt (Styled)',
    image: 'assets/images/characters/gruntStyle.png',
    description:
        'A stylized version of the standard grunt with slightly improved aesthetics.',
    rarity: 'Common',
    type: 'Enemy',
    power: '42',
    defense: '32',
    speed: '41',
    specialAbility: 'None',
    level: '1',
  ),
  Characters(
    name: 'Armored Grunt',
    image: 'assets/images/characters/ArmoredGrunt.png',
    description:
        'Grunt with enhanced armor, providing improved defense against attacks.',
    rarity: 'Uncommon',
    type: 'Enemy',
    power: '45',
    defense: '60',
    speed: '35',
    specialAbility: 'Armor Protection',
    level: '1',
  ),
  Characters(
    name: 'Armored Grunt V2',
    image: 'assets/images/characters/armoredGrunt2.png',
    description:
        'An alternative version of the Armored Grunt with different armor configuration.',
    rarity: 'Uncommon',
    type: 'Enemy',
    power: '47',
    defense: '62',
    speed: '33',
    specialAbility: 'Enhanced Armor',
    level: '1',
  ),
  Characters(
    name: 'Boombox Grunt',
    image: 'assets/images/characters/boomboxGrunt.png',
    description:
        'Grunt carrying a boombox, providing morale boost to nearby allies.',
    rarity: 'Uncommon',
    type: 'Support',
    power: '43',
    defense: '35',
    speed: '38',
    specialAbility: 'Morale Boost',
    level: '1',
  ),
  Characters(
    name: 'Doctor Grunt',
    image: 'assets/images/characters/doctorGrunt.png',
    description:
        'Grunt with medical knowledge, capable of healing allies in battle.',
    rarity: 'Uncommon',
    type: 'Support',
    power: '40',
    defense: '35',
    speed: '45',
    specialAbility: 'Healing',
    level: '1',
  ),
  Characters(
    name: 'Agent',
    image: 'assets/images/characters/agent.png',
    description:
        'More skilled enemies than Grunts, usually armed with better weapons.',
    rarity: 'Uncommon',
    type: 'Enemy',
    power: '55',
    defense: '45',
    speed: '50',
    specialAbility: 'Precise Shot',
    level: '1',
  ),
  Characters(
    name: 'Agent A',
    image: 'assets/images/characters/agentA.png',
    description: 'A specialized Agent with improved training and equipment.',
    rarity: 'Uncommon',
    type: 'Enemy',
    power: '60',
    defense: '50',
    speed: '55',
    specialAbility: 'Advanced Training',
    level: '1',
  ),
  Characters(
    name: 'Armored Agent A',
    image: 'assets/images/characters/armoredAgentA.png',
    description:
        'Agent A with enhanced armor, providing significant protection in combat.',
    rarity: 'Rare',
    type: 'Enemy',
    power: '65',
    defense: '70',
    speed: '45',
    specialAbility: 'Tactical Armor',
    level: '1',
  ),
  Characters(
    name: 'Sheriff',
    image: 'assets/images/characters/sheriff.png',
    description:
        'First antagonist of the series, commands the Grunts and basic operations.',
    rarity: 'Rare',
    type: 'Villain',
    power: '60',
    defense: '50',
    speed: '55',
    specialAbility: 'Command',
    level: '1',
  ),
  Characters(
    name: 'Mag Agent 1',
    image: 'assets/images/characters/magAgent1.png',
    description:
        'First type of Mag Agent, enhanced soldiers with increased size and strength.',
    rarity: 'Epic',
    type: 'Mini-boss',
    power: '85',
    defense: '88',
    speed: '40',
    specialAbility: 'Mag Strength',
    level: '1',
  ),
  Characters(
    name: 'Mag Agent 2',
    image: 'assets/images/characters/magAgent2.png',
    description:
        'Second variation of Mag Agent with different combat specialization.',
    rarity: 'Epic',
    type: 'Mini-boss',
    power: '86',
    defense: '87',
    speed: '42',
    specialAbility: 'Heavy Strike',
    level: '1',
  ),
  Characters(
    name: 'Mag Agent 3',
    image: 'assets/images/characters/magAgent3.png',
    description:
        'Third variation of Mag Agent with unique abilities and tactics.',
    rarity: 'Epic',
    type: 'Mini-boss',
    power: '87',
    defense: '86',
    speed: '43',
    specialAbility: 'Tactical Advance',
    level: '1',
  ),
  Characters(
    name: 'Mag Agent 4',
    image: 'assets/images/characters/magAgent4.png',
    description: 'Fourth variation of Mag Agent with specialized combat role.',
    rarity: 'Epic',
    type: 'Mini-boss',
    power: '88',
    defense: '85',
    speed: '44',
    specialAbility: 'Elite Training',
    level: '1',
  ),
  Characters(
    name: 'Mag Agent 5',
    image: 'assets/images/characters/magAgent5.png',
    description:
        'Fifth variation of Mag Agent, representing the elite of magnified soldiers.',
    rarity: 'Epic',
    type: 'Mini-boss',
    power: '89',
    defense: '89',
    speed: '45',
    specialAbility: 'Superior Tactics',
    level: '1',
  ),
  Characters(
    name: 'Mag Agent (Mad)',
    image: 'assets/images/characters/magAgentMad.png',
    description:
        'Mag Agent in an enraged state, showing increased aggression and power.',
    rarity: 'Epic',
    type: 'Mini-boss',
    power: '92',
    defense: '88',
    speed: '50',
    specialAbility: 'Berserk Mode',
    level: '1',
  ),
  Characters(
    name: 'Clown',
    image: 'assets/images/characters/clown.png',
    description:
        'Standard clown enemy, inspired by but less powerful than Tricky.',
    rarity: 'Uncommon',
    type: 'Enemy',
    power: '60',
    defense: '50',
    speed: '65',
    specialAbility: 'Unpredictable Moves',
    level: '1',
  ),
  Characters(
    name: 'Clown V2',
    image: 'assets/images/characters/clown2.png',
    description:
        'Alternative version of the standard clown with different attack patterns.',
    rarity: 'Uncommon',
    type: 'Enemy',
    power: '62',
    defense: '52',
    speed: '67',
    specialAbility: 'Chaotic Attack',
    level: '1',
  ),
  Characters(
    name: 'Zombie',
    image: 'assets/images/characters/zombie.png',
    description:
        'Reanimated corpse, slow but persistent. Common enemy in later episodes.',
    rarity: 'Common',
    type: 'Enemy',
    power: '50',
    defense: '60',
    speed: '30',
    specialAbility: 'Undead Persistence',
    level: '1',
  ),
  Characters(
    name: 'Scientist',
    image: 'assets/images/characters/scientist.png',
    description:
        'Non-combat personnel working for A.A.H.W., focused on research and development.',
    rarity: 'Uncommon',
    type: 'Support',
    power: '30',
    defense: '25',
    speed: '40',
    specialAbility: 'Research',
    level: '1',
  ),
  Characters(
    name: 'Scrapeface',
    image: 'assets/images/characters/scrapface.png',
    description:
        'A horrifically disfigured experiment, showing signs of immense suffering.',
    rarity: 'Rare',
    type: 'Special',
    power: '70',
    defense: '80',
    speed: '40',
    specialAbility: 'Pain Endurance',
    level: '1',
  ),
  Characters(
    name: 'Hotdog Seller',
    image: 'assets/images/characters/hotdogsaller.png',
    description:
        'A rare civilian character in the series, selling hotdogs amidst the chaos.',
    rarity: 'Rare',
    type: 'Civilian',
    power: '30',
    defense: '20',
    speed: '45',
    specialAbility: 'Hotdog Supply',
    level: '1',
  ),
  Characters(
    name: 'FUN',
    image: 'assets/images/characters/fun.png',
    description:
        'A mysterious entity representing chaos and amusement in the Madness universe.',
    rarity: 'Epic',
    type: 'Special',
    power: '80',
    defense: '70',
    speed: '85',
    specialAbility: 'Chaotic Energy',
    level: '1',
  ),
];
