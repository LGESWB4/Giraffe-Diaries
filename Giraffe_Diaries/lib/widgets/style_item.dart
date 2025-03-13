import 'package:flutter/material.dart';
import '../styles/text_styles.dart';

class StyleItem extends StatelessWidget {
  final String name;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const StyleItem({
    Key? key,
    required this.name,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFFF6AD62), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 스타일 이름 (좌측 상단)
            Text(
              name,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFFF6AD62) : Colors.black,
                fontSize: 20,
                height: 1.2,
              ),
            ),
            // 기린 로고 (우측 하단)
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/giraffe_logo.png',
                height: 50,
                width: 50,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}