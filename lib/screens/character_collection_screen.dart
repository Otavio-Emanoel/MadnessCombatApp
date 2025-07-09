import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/characters.dart' as madness_models;
import '../utils/constants.dart';
import 'character_detail_screen.dart';

class CharacterCollectionScreen extends StatefulWidget {
  const CharacterCollectionScreen({super.key});

  @override
  State<CharacterCollectionScreen> createState() =>
      _CharacterCollectionScreenState();
}

class _CharacterCollectionScreenState extends State<CharacterCollectionScreen>
    with SingleTickerProviderStateMixin {
  List<String> unlockedCharacters = [];
  bool isLoading = true;
  String activeFilter = 'All'; // Default filter
  late TabController _tabController;

  final List<String> rarityFilters = [
    'All',
    'Legendary',
    'Epic',
    'Rare',
    'Uncommon',
    'Common',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUnlockedCharacters();
  }

  @override
  void dispose() {
    _tabController.dispose();

    // Notificar a tela inicial que os dados podem ter mudado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Isso forçará a atualização da tela inicial quando voltar para ela
      Navigator.of(context).pop({'dataChanged': true});
    });

    super.dispose();
  }

  Future<void> _loadUnlockedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Get unlocked characters from SharedPreferences or initialize with empty list
      unlockedCharacters = prefs.getStringList('unlockedCharacters') ?? [];

      // For testing purposes, add some characters if none are unlocked
      if (unlockedCharacters.isEmpty) {
        // Add the first 3 characters as unlocked for demonstration
        if (madness_models.allCharacters.length >= 3) {
          for (var i = 0; i < 3; i++) {
            unlockedCharacters.add(madness_models.allCharacters[i].name);
          }
          prefs.setStringList('unlockedCharacters', unlockedCharacters);
        }
      }

      isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Character Collection'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'UNLOCKED'),
            Tab(text: 'ALL CHARACTERS'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filtros de raridade
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: rarityFilters
                        .map((filter) => _buildRarityFilterChip(filter))
                        .toList(),
                  ),
                ),

                // TabBarView principal
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Personagens desbloqueados
                      _buildCharacterGrid(
                        madness_models.allCharacters
                            .where(
                              (character) =>
                                  unlockedCharacters.contains(character.name) &&
                                  (activeFilter == 'All' ||
                                      character.rarity == activeFilter),
                            )
                            .toList(),
                      ),

                      // Todos os personagens (desbloqueados e bloqueados)
                      _buildCharacterGrid(
                        madness_models.allCharacters
                            .where(
                              (character) =>
                                  (activeFilter == 'All' ||
                                  character.rarity == activeFilter),
                            )
                            .toList(),
                        showLocked: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRarityFilterChip(String filter) {
    final isActive = filter == activeFilter;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(filter),
        selected: isActive,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AppColors.surface,
        selectedColor: filter == 'All'
            ? AppColors.primary
            : _getRarityColor(filter).withOpacity(0.7),
        onSelected: (selected) {
          setState(() {
            activeFilter = filter;
          });
        },
        shape: StadiumBorder(
          side: BorderSide(
            color: isActive
                ? (filter == 'All'
                      ? AppColors.primary
                      : _getRarityColor(filter))
                : Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterGrid(
    List<madness_models.Characters> characters, {
    bool showLocked = false,
  }) {
    if (characters.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, size: 60, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              showLocked
                  ? 'No characters match the filter'
                  : 'No characters unlocked yet',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              showLocked
                  ? 'Try a different filter'
                  : 'Open chests to unlock characters!',
              style: TextStyle(color: AppColors.secondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        final isUnlocked = unlockedCharacters.contains(character.name);
        final isLocked = showLocked && !isUnlocked;

        return _buildCharacterCard(character, isLocked);
      },
    );
  }

  Widget _buildCharacterCard(
    madness_models.Characters character,
    bool isLocked,
  ) {
    return GestureDetector(
      onTap: () {
        if (!isLocked) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharacterDetailScreen(character: character),
            ),
          ).then((result) {
            // Se houver mudanças, recarregar a lista de personagens
            if (result != null && result['dataChanged'] == true) {
              _loadUnlockedCharacters();
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This character is locked. Open chests to unlock!'),
              backgroundColor: AppColors.primary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(character.rarity),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getRarityColor(character.rarity).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Character card contents
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Raridade na parte superior
                  Container(
                    color: _getRarityColor(character.rarity).withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      character.rarity,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Imagem
                  Expanded(
                    flex: 3,
                    child: Container(
                      color: Colors.black26,
                      child: isLocked
                          ? Stack(
                              children: [
                                Image.asset(
                                  character.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  color: Colors.black87,
                                  colorBlendMode: BlendMode.srcATop,
                                ),
                                const Center(
                                  child: Icon(
                                    Icons.lock,
                                    size: 40,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            )
                          : Image.asset(
                              character.image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                  ),

                  // Nome
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      alignment: Alignment.center,
                      child: Text(
                        isLocked ? '???' : character.name,
                        style: TextStyle(
                          color: isLocked ? Colors.white38 : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),

              // Glassmorphism effect for power indicators
              if (!isLocked)
                Positioned(
                  bottom: 40,
                  right: 0,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          border: Border(
                            left: BorderSide(
                              color: _getRarityColor(character.rarity),
                              width: 2,
                            ),
                            top: BorderSide(
                              color: _getRarityColor(character.rarity),
                              width: 2,
                            ),
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              character.power,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
