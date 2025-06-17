import 'package:flutter/material.dart';
import 'package:moelung_new/config/app_routes.dart';
import 'package:moelung_new/utils/app_colors.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> introPages = [
    {
      'image': 'lib/assets/intro/recycle.png',
      'title': 'Revolusi Pengelolaan Sampah',
      'description':
          'Moelung adalah platform digital terintegrasi yang merevolusi pengelolaan sampah di Indonesia, memberdayakan sektor informal dan memfasilitasi ekonomi sirkular.',
    },
    {
      'image': 'lib/assets/intro/pemoelung.png',
      'title': 'Modernisasi Profesi Pemulung',
      'description':
          'Kami mentransformasi profesi pemulung menjadi lebih terstruktur, berkelanjutan, dan profesional melalui teknologi dan kemitraan lokal yang kuat.',
    },
    {
      'image': 'lib/assets/intro/trash-bank.png',
      'title': 'Ekosistem Sampah Transparan',
      'description':
          'Aplikasi Moelung mengorkestrasi alur bisnis pengelolaan sampah yang efisien dan transparan, dari penyetoran hingga distribusi akhir.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (changes with page)
          PageView.builder(
            controller: _pageController,
            itemCount: introPages.length,
            itemBuilder: (context, index) {
              return Image.asset(
                introPages[index]['image']!,
                fit: BoxFit.cover,
              );
            },
          ),
          // Content Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(
                  0.9,
                ), // Semi-transparent white background
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    introPages[_currentPage]['title']!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark, // Use dark color for text
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    introPages[_currentPage]['description']!,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors
                          .darkGrey, // Use darkGrey for descriptive text
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicators (dots)
                      Row(
                        children: List.generate(introPages.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.secondary
                                  : AppColors
                                        .lightGrey, // Highlight current dot
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      // Navigation Button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage < introPages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          } else {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ); // Navigate to login screen
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors
                              .secondary, // Use secondary color for button
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          _currentPage == introPages.length - 1
                              ? 'START'
                              : 'NEXT',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
