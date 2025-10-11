// In timestamp_converter.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'time_stamp_converter.g.dart';

@JsonSerializable(explicitToJson: true)
class TimestampConverter {
  const TimestampConverter();

  static Timestamp fromJson(dynamic json) {
    if (json.runtimeType == Timestamp) {
      return json as Timestamp;
    }
    return Timestamp.fromMicrosecondsSinceEpoch(json as int);
  }

  static int toJson(Timestamp object) => object.millisecondsSinceEpoch;
}
