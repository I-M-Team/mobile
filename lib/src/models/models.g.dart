// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return Question(
    json['id'] as String? ?? '',
    json['personId'] as String? ?? '',
    json['content'] as String? ?? '',
  );
}

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'personId': instance.personId,
      'content': instance.content,
    };

Answer _$AnswerFromJson(Map<String, dynamic> json) {
  return Answer(
    json['id'] as String? ?? '',
    json['personId'] as String? ?? '',
    json['content'] as String? ?? '',
    json['accepted'] as bool? ?? false,
  );
}

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'id': instance.id,
      'personId': instance.personId,
      'content': instance.content,
      'accepted': instance.accepted,
    };

Reaction _$ReactionFromJson(Map<String, dynamic> json) {
  return Reaction(
    json['id'] as String? ?? '',
    json['personId'] as String? ?? '',
  );
}

Map<String, dynamic> _$ReactionToJson(Reaction instance) => <String, dynamic>{
      'id': instance.id,
      'personId': instance.personId,
    };
