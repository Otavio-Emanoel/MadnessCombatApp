# Madness Combat RPG Battle System

## Sistema de Jogo Implementado

### 🎮 Modos de Jogo

1. **Modo Campanha** 
   - 20 níveis progressivos baseados na série Madness Combat
   - Dificuldade crescente com inimigos mais poderosos
   - Recompensas aumentam conforme o nível
   - Progresso salvo automaticamente

2. **Modo Batalha Aleatória**
   - Combates contra equipes geradas aleatoriamente
   - Inimigos balanceados com base no poder da sua equipe
   - Quick Battle disponível imediatamente
   - Modos Ranked e Survival planejados para futuras atualizações

### ⚔️ Sistema de Batalha

#### Mecânicas Principais
- **Batalhas por turnos** com até 3 personagens por equipe
- **Sistema de vida** com barras visuais de HP
- **Cooldown de habilidades especiais** baseado em turnos
- **IA simples** para controlar inimigos automaticamente

#### Tipos de Ações
1. **Ataque Básico**: Dano baseado no poder do personagem
2. **Habilidade Especial**: Habilidades únicas com cooldown
3. **Defender**: Aumenta defesa temporariamente

#### Cálculo de Dano
```
Dano = (Poder do Atacante × 0.8) - (Defesa do Defensor × 0.3)
Defesa ao defender = Defesa base × 1.5
```

### 👥 Seleção de Equipe

#### Funcionalidades
- Seleção de exatamente 3 personagens
- Preview visual dos personagens selecionados
- Informações de stats (Poder, Defesa, Velocidade)
- Sistema de raridade com cores distintas

#### Personagens Básicos
- Sistema automático que desbloqueia personagens básicos se o jogador não tiver nenhum
- Personagens Common e Uncommon liberados automaticamente

### 🏆 Sistema de Recompensas

#### Vitórias em Batalha
- **Base**: 50 moedas por vitória
- **Bônus de Poder Inimigo**: +1 moeda por 10 pontos de poder inimigo
- **Bônus de Velocidade**: +1-15 moedas por vitória rápida (menos turnos)

#### Progresso da Campanha
- Cada nível completado desbloqueia o próximo
- Recompensas crescentes: 50 + (nível × 25) moedas
- Sistema de save automático do progresso

### 🎯 Inteligência Artificial

#### IA dos Inimigos
- **Seleção de Alvo**: Prioriza o primeiro personagem vivo do jogador
- **Uso de Habilidades**: 30% de chance de usar habilidade especial quando disponível
- **Estratégia Básica**: Foca em ataques diretos com ocasional uso de especiais

### 📱 Interface do Usuário

#### Tela de Batalha
- **Campo de Batalha Visual**: Equipes claramente separadas
- **Cards de Personagem**: Imagens, barras de vida, status visual
- **Log de Batalha**: Histórico das ações do turno atual
- **Controles Intuitivos**: Botões de ação com ícones explicativos

#### Navegação
- **Breadcrumb claro**: Modo de Jogo → Seleção de Equipe → Batalha
- **Confirmações**: Dialogs para ações importantes como sair da batalha
- **Feedback Visual**: Animações e cores para indicar estados

### 🔧 Arquitetura Técnica

#### Modelos de Dados
- **BattleCharacter**: Estado de combate dos personagens
- **BattleTeam**: Gerenciamento de equipes
- **BattleManager**: Lógica central de combate
- **BattleAction**: Sistema de ações e turnos

#### Persistência
- **SharedPreferences** para salvar progresso
- **Campanha**: Nível atual e máximo desbloqueado
- **Moedas**: Atualização automática após vitórias

### 🎨 Design Visual

#### Tema Madness Combat
- **Cores**: Paleta escura com acentos em vermelho/dourado
- **Glassmorphism**: Efeitos de vidro fosco para elementos UI
- **Animações**: Transições suaves entre telas
- **Tipografia**: Fontes em caixa alta para títulos importantes

#### Estados Visuais
- **Personagens Nocauteados**: Overlay escuro + ícone X
- **Seleção Ativa**: Bordas destacadas em azul
- **Raridade**: Cores específicas por raridade do personagem
- **Vida Baixa**: Barra vermelha para HP crítico

## 🚀 Próximas Funcionalidades Planejadas

1. **Modo Survival**: Ondas infinitas de inimigos
2. **Ranked Battles**: Sistema competitivo
3. **Itens de Batalha**: Poções e equipamentos
4. **Mais Habilidades**: Sistema expandido de abilities
5. **Animações de Combate**: Efeitos visuais durante ataques

## 🎯 Balanceamento

O sistema foi projetado para ser **justo mas desafiador**:
- Inimigos têm poder ligeiramente menor que o jogador
- Recompensas incentivam tanto rapidez quanto eficiência
- Habilidades especiais têm cooldowns significativos
- Sistema de defesa oferece opções táticas

Este sistema transforma o app de um simples colecionador em um RPG completo com mecânicas de combate estratégicas!
