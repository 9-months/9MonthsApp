import 'package:flutter/material.dart';

class StepScreen extends StatefulWidget {
  const StepScreen({super.key});

  @override
  State<StepScreen> createState() => _StepScreenState();
}

class _StepScreenState extends State<StepScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // PageView for screens
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              _buildFirstScreen(),
              _buildSecondScreen(),
              _buildThirdScreen(),
              _buildFourthScreen(),
            ],
          ),

          // Bottom Navigation
          Positioned(
            left: 0,
            top: 785,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/home'),
                    child: Text(
                      'skip',
                      style: TextStyle(
                        color: const Color(0xFF142108),
                        fontSize: 12,
                        fontFamily: 'Alliance No.2',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  // Progress Indicators
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(width: 8),
                      ...List.generate(
                        4,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Opacity(
                            opacity: index == _currentPage ? 1.0 : 0.3,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Next button
                  GestureDetector(
                    onTap: () {
                      if (_currentPage < 3) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          _currentPage == 3 ? 'continue' : 'next',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Alliance No.2',
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (_currentPage < 3) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 12),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstScreen() {
    return Stack(
      children: [
        // Status Bar Time
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: 402,
            height: 50,
            padding: const EdgeInsets.only(top: 21),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ),

        // Logo and Title
        Positioned(
          left: 73,
          top: 84,
          child: SizedBox(
            width: 260,
            height: 48,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/Logo_Blue.png',
                  width: 56.73,
                  height: 48,
                  color: const Color(0xFF62DFFE),
                ),
                Expanded(
                  child: Text(
                    'Months',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF62DFFE),
                      fontSize: 40,
                      fontFamily: 'Alliance No.2',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Main Text
        Positioned(
          left: 12,
          top: 166,
          child: SizedBox(
            width: 380,
            height: 146,
            child: Text(
              'The ultimate \nPregnancy Support & Wellness App',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF142108),
                fontSize: 30,
                fontFamily: 'Alliance No.2',
                fontWeight: FontWeight.w800,
                height: 1.47,
              ),
            ),
          ),
        ),

        // Pregnant Girl Image
        Positioned(
          left: 158,
          top: 352,
          child: Image.asset(
            'assets/guideScreenImages/pregnant_girl.png',
            width: 86,
            height: 406,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildSecondScreen() {
    return Stack(
      children: [
        // Background container
        Container(
          width: 402,
          height: 874,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
        ),

        // Status Bar Time
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: 402,
            height: 50,
            padding: const EdgeInsets.only(top: 21),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ),

        // Logo and Title
        Positioned(
          left: 76,
          top: 85,
          child: SizedBox(
            width: 260,
            height: 48,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/Logo_Blue.png',
                  width: 56.73,
                  height: 48,
                  color: const Color(0xFF62DFFE),
                ),
                Expanded(
                  child: Text(
                    'Months',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF62DFFE),
                      fontSize: 40,
                      fontFamily: 'Alliance No.2',
                      fontWeight: FontWeight.w800,
                      height: 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Main Text
        Positioned(
          left: 6,
          top: 169,
          child: SizedBox(
            width: 380,
            height: 146,
            child: Text(
              'Get your Partner\nto actively\ntake part in the Journey',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF142108),
                fontSize: 30,
                fontFamily: 'Alliance No.2',
                fontWeight: FontWeight.w800,
                height: 1.47,
              ),
            ),
          ),
        ),

        // Mom Dad Image
        Positioned(
          left: 112,
          top: 355,
          child: SizedBox(
            width: 157,
            height: 403,
            child: Image.asset(
              'assets/guideScreenImages/mom_dad.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThirdScreen() {
    return Stack(
      children: [
        // Background container
        Container(
          width: 402,
          height: 874,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
        ),

        // Logo and Title
        Positioned(
          left: 76,
          top: 85,
          child: SizedBox(
            width: 260,
            height: 48,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/Logo_Blue.png',
                  width: 56.73,
                  height: 48,
                  color: const Color(0xFF62DFFE),
                ),
                Expanded(
                  child: Text(
                    'Months',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF62DFFE),
                      fontSize: 40,
                      fontFamily: 'Alliance No.2',
                      fontWeight: FontWeight.w800,
                      height: 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Main Text
        Positioned(
          left: 6,
          top: 169,
          child: SizedBox(
            width: 380,
            height: 170,
            child: Text(
              'First step towards\nbecoming the\nBest Dad \nyour child Deserves',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF142108),
                fontSize: 30,
                fontFamily: 'Alliance No.2',
                fontWeight: FontWeight.w800,
                height: 1.47,
              ),
            ),
          ),
        ),

        // Dad Baby Image
        Positioned(
          left: 88,
          top: 437,
          child: SizedBox(
            width: 239,
            height: 329,
            child: Image.asset(
              'assets/guideScreenImages/dad.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFourthScreen() {
    return Stack(
      children: [
        // Background container
        Container(
          width: 402,
          height: 874,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: Colors.white),
        ),

        // Logo and Title
        Positioned(
          left: 76,
          top: 85,
          child: SizedBox(
            width: 260,
            height: 48,
            child: Row(
              children: [
                Image.asset(
                  'assets/images/Logo_Blue.png',
                  width: 56.73,
                  height: 48,
                  color: const Color(0xFF62DFFE),
                ),
                Expanded(
                  child: Text(
                    'Months',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF62DFFE),
                      fontSize: 40,
                      fontFamily: 'Alliance No.2',
                      fontWeight: FontWeight.w800,
                      height: 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Main Text
        Positioned(
          left: 11,
          top: 211,
          child: SizedBox(
            width: 380,
            height: 146,
            child: Text(
              'Emergency Alert Button\nat your fingertips',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF142108),
                fontSize: 30,
                fontFamily: 'Alliance No.2',
                fontWeight: FontWeight.w800,
                height: 1.47,
              ),
            ),
          ),
        ),

        // Emergency Button Image
        Positioned(
          left: 104,
          top: 456,
          child: SizedBox(
            width: 180,
            height: 290,
            child: Image.asset(
              'assets/guideScreenImages/watch.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
