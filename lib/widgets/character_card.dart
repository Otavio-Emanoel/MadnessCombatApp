// Este é um exemplo de como usar imagens
// Coloque-o em um widget como `FeaturedCharacter` e chame em sua tela

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CharacterCard extends StatelessWidget {
  final String name;
  final String imagePath;
  final String description;

  const CharacterCard({
    super.key,
    required this.name,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Imagem do personagem
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.borderRadiusMedium - 2),
              topRight: Radius.circular(AppDimensions.borderRadiusMedium - 2),
            ),
            child: Image.asset(
              imagePath,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Informações do personagem
          Padding(
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.toUpperCase(), style: AppTextStyles.title),
                SizedBox(height: AppDimensions.paddingSmall),
                Text(
                  description,
                  style: AppTextStyles.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Exemplo de uso em outra tela:
/*
import 'widgets/character_card.dart';

// Dentro de um widget:
CharacterCard(
  name: 'Hank J. Wimbleton',
  imagePath: '${AppImages.charactersPath}hank.png',
  description: 'The main protagonist of the Madness Combat series.',
),
*/
