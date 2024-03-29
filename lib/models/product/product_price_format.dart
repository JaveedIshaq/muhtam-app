import 'package:json_annotation/json_annotation.dart';

part 'product_price_format.g.dart';

@JsonSerializable()
class ProductPriceFormat {
  @JsonKey(name: 'regular_price', required: true, defaultValue: '0.0')
  String? regularPrice;
  @JsonKey(name: 'sale_price')
  String? salePrice;
  int? percent;

  ProductPriceFormat({
    this.regularPrice,
    this.salePrice,
    this.percent,
  });

  factory ProductPriceFormat.fromJson(Map<String, dynamic> json) => _$ProductPriceFormatFromJson(json);
  Map<String, dynamic> toJson() => _$ProductPriceFormatToJson(this);
}
