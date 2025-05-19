import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

/// Barra de navegação customizada com círculo central elevado
class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
    height: 60.5, 
      child: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        iconSize: 36,
        currentIndex: currentIndex,
        onTap: onTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 36,
              color: currentIndex == 0
                  ? AppTheme.primaryColor
                  : AppTheme.textColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.book,
              size: 36,
              color: currentIndex == 1
                  ? AppTheme.primaryColor
                  : AppTheme.textColor,
            ),
            label: '',
          ),

          // Ícone central
          BottomNavigationBarItem(
            icon: Transform.translate(
              offset: const Offset(0, -34), // metade do círculo pra fora
              child: Container(
                width: 68,  // 60 interno + 4*2 de borda
                height: 68,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentIndex == 2
                        ? AppTheme.primaryColor
                        : AppTheme.boxColor,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    '../assets/luizinho.png',
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
            label: '',
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.security,
              size: 36,
              color: currentIndex == 3
                  ? AppTheme.primaryColor
                  : AppTheme.textColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 36,
              color: currentIndex == 4
                  ? AppTheme.primaryColor
                  : AppTheme.textColor,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
