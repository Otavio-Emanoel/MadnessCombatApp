import 'package:flutter/material.dart';

class ChestType {
  final String name;
  final int price;
  final double characterChance;
  final Color color;
  final String image;

  const ChestType({
    required this.name,
    required this.price,
    required this.characterChance,
    required this.color,
    required this.image,
  });

  // Getter para compatibilidade com tela de baús
  double get chance => characterChance;

  // Lista estática para uso na tela de baús
  static List<ChestType> chests = chestTypes;
}

const List<ChestType> chestTypes = [
  ChestType(
    name: 'Common',
    price: 100,
    characterChance: 0.3,
    color: Color(0xFFB0BEC5),
    image: 'assets/images/icons/chest_common.png',
  ),
  ChestType(
    name: 'Rare',
    price: 300,
    characterChance: 0.6,
    color: Color(0xFF1976D2),
    image: 'assets/images/icons/chest_rare.png',
  ),
  ChestType(
    name: 'Legendary',
    price: 800,
    characterChance: 0.9,
    color: Color(0xFFFFD600),
    image: 'assets/images/icons/chest_legendary.png',
  ),
];
