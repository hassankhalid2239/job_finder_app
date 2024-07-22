import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../Login&Signup/login_page.dart';
import 'intro_contents.dart';

class OnBoardScreen extends StatefulWidget {
  const OnBoardScreen({super.key});

  @override
  State<OnBoardScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends State<OnBoardScreen> {
  int currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).colorScheme.onSurface,
            statusBarIconBrightness: Theme.of(context).brightness),
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: PageView.builder(
                  controller: _controller,
                  itemCount: contents.length,
                  onPageChanged: (int index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (_, i) {
                    return SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: w * 0.065),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(contents[i].image),
                              radius: 150,
                              backgroundColor: Color(contents[i].color),
                            ),
                            SizedBox(
                              height: h * 0.061,
                              // height: 50.h,
                            ),
                            Text(
                              contents[i].title,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            SizedBox(
                              height: h * 0.037,
                              // height: 30.h,
                            ),
                            Text(
                              contents[i].description,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: h * 0.049, right: w * 0.078),
              // padding: EdgeInsets.only(bottom: 40.h,right: 30.w),
              child: Align(
                alignment: Alignment.bottomRight,
                child: SmoothPageIndicator(
                  controller: _controller,
                  count: contents.length,
                  effect: WormEffect(
                    dotWidth: w * 0.026,
                    // dotWidth: 10.w,
                    dotHeight: h * 0.013,
                    // dotHeight: 10.h,
                    dotColor: Theme.of(context).colorScheme.secondaryContainer,
                    activeDotColor: const Color(0xff5800FF),
                  ),
                  onDotClicked: (index) {
                    _controller.animateToPage(index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Wrap(
        children: [
          SizedBox.fromSize(
            size: const Size.square(60),
            child: FloatingActionButton(
              onPressed: () {
                if (currentIndex == contents.length - 1) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                }
              },
              shape: const CircleBorder(),
              backgroundColor: const Color(0xff5800FF),
              child: const Icon(
                Icons.arrow_forward_ios_sharp,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: h * 0.006),
            child: TextButton(
                style: const ButtonStyle(
                  splashFactory: InkRipple.splashFactory,
                ),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                },
                child: Text('Skip',
                    style: Theme.of(context).textTheme.bodyMedium)),
          )
        ],
      ),
    );
  }
}
