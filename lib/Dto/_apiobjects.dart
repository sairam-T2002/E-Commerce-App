class ProductDto {
  int? prdId;
  String? name;
  bool? isVeg;
  bool? isBestSeller;
  int? price;
  int? imageSrl;
  int? categoryId;
  String? imgUrl;
  int? stockCount;
  double? rating;
  int? ratingCount;
  ProductDto({
    this.prdId,
    this.name,
    this.isVeg,
    this.isBestSeller,
    this.price,
    this.imageSrl,
    this.categoryId,
    this.imgUrl,
    this.stockCount,
    this.rating,
    this.ratingCount,
  });
}

class CategoryDto {
  int? categoryId;
  String? name;
  String? imgUrl;
  CategoryDto({this.categoryId, this.name, this.imgUrl});
}

class ApiCredentials {
  String username;
  String accessToken;
  String refreshToken;
  ApiCredentials(
      {required this.username,
      required this.accessToken,
      required this.refreshToken});
}
