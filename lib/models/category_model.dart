class CategoryModel {
  final String title;
  final String? image;
  final String? svgSrc;
  final String? thumbnail;
  final String? label;
  final List<CategoryModel>? subCategories;

  CategoryModel({
    required this.title,
    this.image,
    this.svgSrc,
    this.thumbnail,
    this.label,
    this.subCategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      title: json['title'] ?? '',
      image: json['image'],
      svgSrc: json['svgSrc'],
      thumbnail: json['thumbnail'],
      label: json['label'],
      subCategories: json['subCategories'] != null
          ? List<CategoryModel>.from(
              (json['subCategories'] as List)
                  .map((item) => CategoryModel.fromJson(item)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
      'svgSrc': svgSrc,
      'thumbnail': thumbnail,
      'label': label,
      'subCategories': subCategories?.map((sub) => sub.toJson()).toList(),
    };
  }
}

final List<CategoryModel> aliExpressStyleCategories = [
  CategoryModel(
    title: "Women's Fashion",
    image: "https://imgur.com/a/F89VGr2.jpg",
    label: "Hot",
    subCategories: [
      CategoryModel(title: "Dresses", thumbnail: "https://i.imgur.com/YGIoZrY.png"),
      CategoryModel(title: "Tops & Blouses", thumbnail: "https://i.imgur.com/9bq8dOT.png"),
      CategoryModel(title: "Sweaters", thumbnail: "https://i.imgur.com/6QotXCh.png"),
      CategoryModel(title: "Skirts", thumbnail: "https://i.imgur.com/Uu1YTfC.png"),
    ],
  ),
  // Add the rest here...
];
