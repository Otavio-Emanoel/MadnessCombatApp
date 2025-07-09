import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chest_type.dart';
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

class _ChestScreenState extends State<ChestScreen> {
  bool isOpening = false;
  ChestType? openedChest;
  String? rewardMessage;
  int coins = 0;

  @override
  void initState() {
    super.initState();
    coins = widget.coins;
  }

  Future<void> _openChest(ChestType chest) async {
    if (isOpening || coins < chest.price) return;
    setState(() {
      isOpening = true;
      openedChest = chest;
      rewardMessage = null;
    });
    await Future.delayed(const Duration(milliseconds: 1200)); // animação
    // Sorteio simples: personagem ou "Nada"
    final rand = (chest.chance * 100).toInt();
    final gotCharacter = (rand > 0)
        ? (DateTime.now().millisecond % 100 < rand)
        : false;
    setState(() {
      coins -= chest.price;
      rewardMessage = gotCharacter
          ? 'Parabéns! Você ganhou um personagem!'
          : 'Nada encontrado... Tente novamente!';
      isOpening = false;
    });
    widget.onCoinsChanged(coins);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
  }

  @override
  Widget build(BuildContext context) {
    final chests = ChestType.chests;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Baús'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Coins: $coins', style: AppTextStyles.subtitle),
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
                            child: Image.asset(
                              chest.image,
                              fit: BoxFit.contain,
                              color: isThisOpening
                                  ? chest.color.withOpacity(0.7)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(chest.name, style: AppTextStyles.title),
                          const SizedBox(height: 6),
                          Text(
                            'Preço: ${chest.price} coins',
                            style: AppTextStyles.body,
                          ),
                          Text(
                            'Chance de personagem: ${(chest.chance * 100).toStringAsFixed(0)}%',
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
                                : const Text('Abrir Baú'),
                          ),
                          if (isThisOpening && rewardMessage == null)
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Abrindo...',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                          if (openedChest == chest && rewardMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                rewardMessage!,
                                style: TextStyle(
                                  color: gotRewardColor(rewardMessage!),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
}

Color gotRewardColor(String msg) {
  if (msg.contains('Parabéns')) return AppColors.secondary;
  return Colors.white70;
}
