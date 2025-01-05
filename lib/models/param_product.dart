class ParamProduct {
  String productId;
  String collection;
  void Function()? callBack;

  ParamProduct({
    required this.productId,
    this.collection = "products",
    this.callBack,
  });
}
