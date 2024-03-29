import 'package:json_annotation/json_annotation.dart';

part 'gateway.g.dart';

@JsonSerializable()
class Gateway {
  String id;

  @JsonKey(fromJson: _toString)
  String? title;

  @JsonKey(fromJson: _toString)
  String? description;

  bool enabled;

  @JsonKey(fromJson: _toMap)
  Map<String, dynamic> settings;

  Gateway({
    required this.id,
    this.title,
    this.description,
    required this.enabled,
    required this.settings,
  });

  static Map<String, dynamic> _toMap(dynamic value) {
    Map<String, dynamic> data = {};
    if (value is Map) {
      data = value.map((key, value) => MapEntry(key.toString(), value));
    }
    return data;
  }

  static String? _toString(dynamic value) {
    if (value is String) {
      return value;
    }
    return "";
  }

  factory Gateway.fromJson(Map<String, dynamic> json) => _$GatewayFromJson(json);

  Map<String, dynamic> toJson() => _$GatewayToJson(this);
}
