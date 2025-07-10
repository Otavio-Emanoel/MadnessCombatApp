import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/characters.dart' as madness_models;
import '../utils/constants.dart';
import 'battle_screen_v2.dart';

class TeamSelectionScreen extends StatefulWidget {
  final bool isCampaign;
  final int? campaignLevel;

  const TeamSelectionScreen({
    super.key,
    this.isCampaign = false,
    this.campaignLevel,
  });

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  List<madness_models.Characters> unlockedCharacters = [];
  List<madness_models.Characters> selectedTeam = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnlockedCharacters();
  }

  Future<void> _loadUnlockedCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedNames = prefs.getStringList('unlockedCharacters') ?? [];

    setState(() {
      unlockedCharacters = madness_models.allCharacters
          .where((char) => unlockedNames.contains(char.name))
          .toList();
      isLoading = false;
    });

    // Se não tem personagens desbloqueados, adiciona alguns básicos
    if (unlockedCharacters.isEmpty) {
      _unlockBasicCharacters();
    }
  }

  Future<void> _unlockBasicCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> basicCharacters = ['Grunt', 'Agent', 'Soldado'];

    // Encontra personagens básicos na lista
    List<madness_models.Characters> basicsToUnlock = madness_models
        .allCharacters
        .where(
          (char) => basicCharacters.any((basic) => char.name.contains(basic)),
        )
        .take(3)
        .toList();

    if (basicsToUnlock.isNotEmpty) {
      List<String> unlockedNames = basicsToUnlock
          .map((char) => char.name)
          .toList();
      await prefs.setStringList('unlockedCharacters', unlockedNames);

      setState(() {
        unlockedCharacters = basicsToUnlock;
      });
    }
  }

  void _toggleCharacterSelection(madness_models.Characters character) {
    setState(() {
      if (selectedTeam.contains(character)) {
        selectedTeam.remove(character);
      } else if (selectedTeam.length < 3) {
        selectedTeam.add(character);
      }
    });
  }

  void _startBattle() {
    if (selectedTeam.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must select exactly 3 characters!'),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BattleScreenV2(
          playerTeam: selectedTeam,
          isCampaign: widget.isCampaign,
          campaignLevel: widget.campaignLevel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isCampaign ? 'Campaign Team' : 'Battle Team'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showTeamInfo();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'SELECT YOUR TEAM',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose 3 characters for battle',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  'Selected: ${selectedTeam.length}/3',
                  style: TextStyle(
                    color: selectedTeam.length == 3
                        ? AppColors.green
                        : AppColors.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista de personagens selecionados
          if (selectedTeam.isNotEmpty)
            Container(
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedTeam.length,
                itemBuilder: (context, index) {
                  return _buildSelectedCharacterCard(selectedTeam[index]);
                },
              ),
            ),

          const SizedBox(height: 16),

          // Lista de personagens disponíveis
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: unlockedCharacters.length,
              itemBuilder: (context, index) {
                return _buildCharacterCard(unlockedCharacters[index]);
              },
            ),
          ),

          // Botão de iniciar batalha
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedTeam.length == 3
                      ? AppColors.primary
                      : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: selectedTeam.length == 3 ? _startBattle : null,
                child: Text(
                  'START BATTLE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterCard(madness_models.Characters character) {
    bool isSelected = selectedTeam.contains(character);

    return GestureDetector(
      onTap: () => _toggleCharacterSelection(character),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : _getRarityColor(character.rarity),
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Raridade
              Container(
                color: _getRarityColor(character.rarity).withOpacity(0.8),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  character.rarity,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Imagem
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    Container(
                      color: Colors.black26,
                      child: Image.asset(
                        character.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    if (isSelected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Nome e stats
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        character.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatChip(
                            Icons.flash_on,
                            character.power,
                            Colors.orange,
                          ),
                          _buildStatChip(
                            Icons.shield,
                            character.defense,
                            Colors.blue,
                          ),
                          _buildStatChip(
                            Icons.speed,
                            character.speed,
                            Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCharacterCard(madness_models.Characters character) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              child: Image.asset(
                character.image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              character.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  void _showTeamInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Team Selection Tips',
          style: TextStyle(color: AppColors.primary),
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '• Select 3 characters for your team',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '• Balance your team with different roles',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '• Higher rarity characters are more powerful',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 8),
              Text(
                '• Consider Power, Defense, and Speed stats',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'GOT IT',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
