// lib/features/screens/widgets/reaction_picker.dart
import 'package:flutter/material.dart';

class ReactionPicker extends StatefulWidget {
  final int? selectedReaction;
  final Function(int) onReactionSelected;
  final VoidCallback onClose;

  const ReactionPicker({
    super.key,
    this.selectedReaction,
    required this.onReactionSelected,
    required this.onClose,
  });

  @override
  State<ReactionPicker> createState() => _ReactionPickerState();
}

class _ReactionPickerState extends State<ReactionPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  static const List<Map<String, dynamic>> reactions = [
    {'type': 1, 'emoji': '👍', 'label': 'إعجاب', 'color': Colors.blue},
    {'type': 2, 'emoji': '❤️', 'label': 'حب', 'color': Colors.red},
    {'type': 3, 'emoji': '😂', 'label': 'ضحك', 'color': Colors.amber},
    {'type': 4, 'emoji': '😡', 'label': 'غضب', 'color': Colors.orange},
    {'type': 5, 'emoji': '😢', 'label': 'حزن', 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animations = List.generate(reactions.length, (index) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(index * 0.05, 1.0, curve: Curves.elasticOut),
      );
    });
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(reactions.length, (index) {
                final reaction = reactions[index];
                final isSelected = widget.selectedReaction == reaction['type'];
                
                return GestureDetector(
                  onTap: () => widget.onReactionSelected(reaction['type']),
                  child: AnimatedBuilder(
                    animation: _animations[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 0.8 + (_animations[index].value * 0.4),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (reaction['color'] as Color).withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              Text(
                                reaction['emoji'],
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reaction['label'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? reaction['color']
                                      : Colors.grey[600],
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}