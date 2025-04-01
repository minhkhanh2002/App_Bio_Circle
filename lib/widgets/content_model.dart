class UnboardingContent{
  String image;
  String title;
  String description;
  UnboardingContent(
      {required this.description, required this.image, required this.title});
}
List<UnboardingContent> contents=[
  UnboardingContent(description: 'Xem minh phuong co nho minh khanh khong\n More tilte here',
                    image: "images/screen1.png",
                    title: 'Select from our\n Best Menu'),
                    UnboardingContent(description: 'Xem minh phuong co nho minh khanh khong\n More tilte here',
                    image: "images/screen1.png",
                        title: 'Select from our\n Best Menu'),
  UnboardingContent(description: 'Xem minh phuong co nho minh khanh khong\n More tilte here',
      image: "images/screen1.png",
      title: 'Select from our\n Best Menu'),
];