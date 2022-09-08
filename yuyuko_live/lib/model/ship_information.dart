import 'package:freezed_annotation/freezed_annotation.dart';

part 'ship_information.freezed.dart';
part 'ship_information.g.dart';

@freezed
abstract class ShipInformation with _$ShipInformation {
  const factory ShipInformation({
    int? shipId,
    ShipInfo? shipInfo,
    ShipPRData? data,
  }) = _ShipInformation;

  factory ShipInformation.fromJson(Map<String, dynamic> json) =>
      _$ShipInformationFromJson(json);
}

@freezed
class ShipPRData with _$ShipPRData {
  /// See https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models
  const ShipPRData._();

  const factory ShipPRData({
    double? winRate,
    double? averageDamageDealt,
    double? averageFrags,
  }) = _ShipPRData;

  bool get isAvailable =>
      winRate != null && averageDamageDealt != null && averageFrags != null;

  factory ShipPRData.fromJson(Map<String, dynamic> json) =>
      _$ShipPRDataFromJson(json);
}

@freezed
abstract class ShipInfo with _$ShipInfo {
  const factory ShipInfo({
    String? nameCn,
    String? nameEnglish,
    int? level,
    String? shipType,
    String? country,
    String? imgSmall,
    String? imgLarge,
    String? imgMedium,
    String? shipIndex,
    String? groupType,
  }) = _ShipInfo;

  factory ShipInfo.fromJson(Map<String, dynamic> json) =>
      _$ShipInfoFromJson(json);
}
