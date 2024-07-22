class OnBoardContent {
  String image;
  String title;
  String description;
  int color;
  OnBoardContent(
      {required this.image,
      required this.title,
      required this.description,
      required this.color});
}

List<OnBoardContent> contents = [
  OnBoardContent(
      title: 'Search your job',
      color: 0xffEDAE3C,
      image: 'assets/images/onboard1.png',
      description:
          'Figure out your top five priorities whether it is company culture, salary.'),
  OnBoardContent(
      title: 'Browse jobs list',
      color: 0xff4A73B8,
      image: 'assets/images/onboard2.PNG',
      description:
          'Our job include several industries, so you can find the best job for you.'),
  OnBoardContent(
      title: 'Apply to best jobs',
      color: 0xffED6E7A,
      image: 'assets/images/onboard3.png',
      description:
          'You can apply to your desirable jobs very quickly and easily with ease.'),
  OnBoardContent(
      title: 'Make your career',
      color: 0xff5D4F9C,
      image: 'assets/images/onboard4.png',
      description:
          'We help you find your dream job based on your skillet, location, demand.')
];
