import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'team_selection_screen.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  int currentCampaignLevel = 1;
  int maxUnlockedLevel = 1;

  @override
  void initState() {
    super.initState();
    _loadCampaignProgress();
  }

  Future<void> _loadCampaignProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentCampaignLevel = prefs.getInt('campaignLevel') ?? 1;
      maxUnlockedLevel = prefs.getInt('maxCampaignLevel') ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Campaign Mode'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(20),
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
                    'MADNESS CAMPAIGN',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Follow the story of Nevada\'s chaos',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatInfo(
                        'Current Level',
                        currentCampaignLevel.toString(),
                      ),
                      _buildStatInfo(
                        'Max Unlocked',
                        maxUnlockedLevel.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Levels grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 20, // 20 níveis de campanha
                itemBuilder: (context, index) {
                  int level = index + 1;
                  return _buildLevelCard(level);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLevelCard(int level) {
    bool isUnlocked = level <= maxUnlockedLevel;
    bool isCurrent = level == currentCampaignLevel;
    bool isCompleted = level < currentCampaignLevel;

    Color cardColor = isCompleted
        ? AppColors.green
        : isCurrent
        ? AppColors.primary
        : isUnlocked
        ? AppColors.secondary
        : Colors.grey;

    IconData iconData = isCompleted
        ? Icons.check_circle
        : isCurrent
        ? Icons.play_circle_fill
        : isUnlocked
        ? Icons.radio_button_unchecked
        : Icons.lock;

    return GestureDetector(
      onTap: isUnlocked ? () => _startLevel(level) : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardColor, width: 2),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: cardColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: cardColor, size: 32),
            const SizedBox(height: 8),
            Text(
              'Level $level',
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.white38,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            if (isUnlocked)
              Text(
                _getLevelDescription(level),
                style: const TextStyle(color: Colors.white70, fontSize: 10),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  String _getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'First Blood';
      case 2:
        return 'Agents';
      case 3:
        return 'The Facility';
      case 4:
        return 'Madness';
      case 5:
        return 'Redeemer';
      case 6:
        return 'Avenger';
      case 7:
        return 'Antipathy';
      case 8:
        return 'Depredation';
      case 9:
        return 'Aggregation';
      case 10:
        return 'Abrogation';
      case 11:
        return 'Expurgation';
      case 12:
        return 'Consternation';
      case 13:
        return 'Project Nexus';
      case 14:
        return 'The Auditor';
      case 15:
        return 'Tricky Returns';
      case 16:
        return 'The Machine';
      case 17:
        return 'Final Stand';
      case 18:
        return 'Chaos';
      case 19:
        return 'Nevada Hell';
      case 20:
        return 'The End?';
      default:
        return 'Battle $level';
    }
  }

  void _startLevel(int level) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Level $level',
          style: const TextStyle(color: AppColors.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getLevelDescription(level),
              style: const TextStyle(
                color: AppColors.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _getLevelStory(level),
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Difficulty: ${_getLevelDifficulty(level)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: AppColors.secondary,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Reward: ${_getLevelReward(level)} coins',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamSelectionScreen(
                    isCampaign: true,
                    campaignLevel: level,
                  ),
                ),
              );
            },
            child: const Text(
              'START BATTLE',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelStory(int level) {
    switch (level) {
      case 1:
        return 'The beginning of the madness. Face off against basic grunts as Hank starts his rampage.';
      case 2:
        return 'The agency sends their agents to stop you. Time to show them what madness really means.';
      case 3:
        return 'Infiltrate the mysterious facility and uncover the truth behind the conspiracy.';
      case 4:
        return 'The gloves are off. Full-scale warfare erupts across Nevada.';
      case 5:
        return 'A mysterious figure appears to challenge Hank. Can you overcome the Redeemer?';
      default:
        return 'Continue the story of madness and chaos in Nevada. Face increasingly dangerous enemies.';
    }
  }

  String _getLevelDifficulty(int level) {
    if (level <= 3) return 'Easy';
    if (level <= 7) return 'Normal';
    if (level <= 12) return 'Hard';
    if (level <= 17) return 'Very Hard';
    return 'Extreme';
  }

  int _getLevelReward(int level) {
    return 50 + (level * 25); // Aumenta a recompensa com o nível
  }
}
