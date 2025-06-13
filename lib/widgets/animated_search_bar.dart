import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatelessWidget {
  final bool isExpanded;
  final TextEditingController controller;
  final Animation<double> scaleAnimation;
  final VoidCallback toggleExpansion;

  const AnimatedSearchBar({
    Key? key,
    required this.isExpanded,
    required this.controller,
    required this.scaleAnimation,
    required this.toggleExpansion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: GestureDetector(
            onTap: toggleExpansion,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              height: 48,
              decoration: BoxDecoration(
                color: isExpanded ? Colors.white : Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isExpanded ? const Color(0xFF4CAF50) : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: isExpanded
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: isExpanded ? const Color(0xFF4CAF50) : Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search products...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.tune_rounded,
                      color: isExpanded ? const Color(0xFF4CAF50) : Colors.grey[600],
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
