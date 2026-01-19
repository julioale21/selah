import '../../domain/entities/verse.dart';

class VerseModel extends Verse {
  const VerseModel({
    required super.id,
    required super.textEs,
    super.textEn,
    required super.reference,
    required super.book,
    required super.chapter,
    required super.verseStart,
    super.verseEnd,
    required super.category,
    super.tags,
    super.isFavorite,
  });

  factory VerseModel.fromEntity(Verse verse) {
    return VerseModel(
      id: verse.id,
      textEs: verse.textEs,
      textEn: verse.textEn,
      reference: verse.reference,
      book: verse.book,
      chapter: verse.chapter,
      verseStart: verse.verseStart,
      verseEnd: verse.verseEnd,
      category: verse.category,
      tags: verse.tags,
      isFavorite: verse.isFavorite,
    );
  }

  factory VerseModel.fromMap(Map<String, dynamic> map, {bool isFavorite = false}) {
    return VerseModel(
      id: map['id'] as String,
      textEs: map['text_es'] as String,
      textEn: map['text_en'] as String?,
      reference: map['reference'] as String,
      book: map['book'] as String,
      chapter: map['chapter'] as int,
      verseStart: map['verse_start'] as int,
      verseEnd: map['verse_end'] as int?,
      category: map['category'] as String,
      tags: (map['tags'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      isFavorite: isFavorite,
    );
  }

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    return VerseModel(
      id: json['id'] as String,
      textEs: json['text_es'] as String,
      textEn: json['text_en'] as String?,
      reference: json['reference'] as String,
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verseStart: json['verse_start'] as int,
      verseEnd: json['verse_end'] as int?,
      category: json['category'] as String,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isFavorite: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text_es': textEs,
      'text_en': textEn,
      'reference': reference,
      'book': book,
      'chapter': chapter,
      'verse_start': verseStart,
      'verse_end': verseEnd,
      'category': category,
      'tags': tags.join(','),
    };
  }
}
