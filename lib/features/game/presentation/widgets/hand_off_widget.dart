import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mindclash/core/extensions/question_extensions.dart';
import 'package:mindclash/core/theme/app_colors.dart';
import 'package:mindclash/core/theme/app_radius.dart';
import 'package:mindclash/core/theme/app_spacing.dart';
import 'package:mindclash/core/theme/app_typography.dart';
import 'package:mindclash/features/game/domain/entities/game_data.dart';
import 'package:mindclash/features/game/presentation/providers/game_notifier_provider.dart';

/// Pass-the-device screen shown between turns.
///
/// Displays the next team's name and a "Show Question" button.
/// When random modes are disabled, shows category/difficulty selectors.
/// Prevents accidental question reveals in pass-and-play mode.
class HandOffWidget extends ConsumerStatefulWidget {
  /// Creates a [HandOffWidget].
  const HandOffWidget({
    required this.data,
    required this.onShowQuestion,
    super.key,
  });

  /// Current game data snapshot.
  final GameData data;

  /// Called when the player taps "Show Question".
  final VoidCallback onShowQuestion;

  @override
  ConsumerState<HandOffWidget> createState() => _HandOffWidgetState();
}

class _HandOffWidgetState extends ConsumerState<HandOffWidget> {
  String? _selectedCategory;
  String? _selectedDifficulty;

  /// Available categories (derived from game's selected categories).
  List<String> get _availableCategories {
    // Get unique categories from all loaded questions
    final categories = widget.data.questions
        .map((q) => q.category)
        .where((cat) => cat != 'unknown')
        .toSet()
        .toList()
      ..sort();
    return categories;
  }

  /// Available difficulty levels
  static const _difficulties = ['easy', 'medium', 'hard'];

  @override
  void initState() {
    super.initState();
    // Initialize with first available options
    if (_availableCategories.isNotEmpty) {
      _selectedCategory = _availableCategories.first;
    }
    _selectedDifficulty = _difficulties.first;
  }

  /// Returns a human-readable display name for a category.
  String _categoryDisplayName(String category) {
    return switch (category) {
      'science' => 'Science',
      'geography' => 'Geography',
      'history' => 'History',
      'sports' => 'Sports',
      'general_knowledge' => 'General',
      _ => category,
    };
  }

  /// Returns a human-readable display name for difficulty.
  String _difficultyDisplayName(String difficulty) {
    return difficulty[0].toUpperCase() + difficulty.substring(1);
  }

  void _handleShowQuestion() {
    final notifier = ref.read(gameProvider.notifier);

    // Set preferences based on random modes
    if (!widget.data.config.randomCategory) {
      notifier.setCategoryPreference(_selectedCategory);
    }
    if (!widget.data.config.randomDifficulty) {
      notifier.setDifficultyPreference(_selectedDifficulty);
    }

    // Trigger question display
    widget.onShowQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.currentTeamIndex >= widget.data.teams.length) {
      return const Center(child: Text('Invalid team index'));
    }
    final player = widget.data.teams[widget.data.currentTeamIndex];
    final questionNumber = widget.data.currentQuestionIndex + 1;
    final totalQuestions = widget.data.config.questionsPerRound;

    final showCategorySelector = !widget.data.config.randomCategory;
    final showDifficultySelector = !widget.data.config.randomDifficulty;

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Round ${widget.data.currentRound} of ${widget.data.config.numberOfRounds}',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Question $questionNumber of $totalQuestions',
                style: AppTypography.caption,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                player.name,
                style: AppTypography.heading.copyWith(
                  color: AppColors.secondary,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                "It's your turn!",
                style: AppTypography.subheading,
                textAlign: TextAlign.center,
              ),

              // Category selector (shown only when random mode is OFF)
              if (showCategorySelector) ...[
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Select Category:',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.lgAll,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: _availableCategories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(_categoryDisplayName(cat)),
                            );
                          }).toList(),
                          onChanged: (cat) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          final shuffled = [..._availableCategories]..shuffle();
                          _selectedCategory = shuffled.first;
                        });
                      },
                      icon: const Icon(Icons.shuffle, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                      ),
                      tooltip: 'Randomize category',
                    ),
                  ],
                ),
              ],

              // Difficulty selector (shown only when random mode is OFF)
              if (showDifficultySelector) ...[
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Select Difficulty:',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<String>(
                        segments: _difficulties.map((diff) {
                          return ButtonSegment(
                            value: diff,
                            label: Text(_difficultyDisplayName(diff)),
                          );
                        }).toList(),
                        selected: {_selectedDifficulty!},
                        onSelectionChanged: (selected) {
                          setState(() {
                            _selectedDifficulty = selected.first;
                          });
                        },
                        style: SegmentedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          selectedBackgroundColor: AppColors.primary,
                          selectedForegroundColor: AppColors.textPrimary,
                          foregroundColor: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton.filled(
                      onPressed: () {
                        setState(() {
                          final shuffled = [..._difficulties]..shuffle();
                          _selectedDifficulty = shuffled.first;
                        });
                      },
                      icon: const Icon(Icons.shuffle, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textPrimary,
                      ),
                      tooltip: 'Randomize difficulty',
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleShowQuestion,
                  child: const Text('Show Question'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
