import 'package:equatable/equatable.dart';

class Verse extends Equatable {
  final String id;
  final String textEs;
  final String? textEn;
  final String reference;
  final String book;
  final int chapter;
  final int verseStart;
  final int? verseEnd;
  final String category;
  final List<String> tags;
  final bool isFavorite;

  const Verse({
    required this.id,
    required this.textEs,
    this.textEn,
    required this.reference,
    required this.book,
    required this.chapter,
    required this.verseStart,
    this.verseEnd,
    required this.category,
    this.tags = const [],
    this.isFavorite = false,
  });

  String get displayReference {
    if (verseEnd != null && verseEnd != verseStart) {
      return '$book $chapter:$verseStart-$verseEnd';
    }
    return '$book $chapter:$verseStart';
  }

  Verse copyWith({
    String? id,
    String? textEs,
    String? textEn,
    String? reference,
    String? book,
    int? chapter,
    int? verseStart,
    int? verseEnd,
    String? category,
    List<String>? tags,
    bool? isFavorite,
  }) {
    return Verse(
      id: id ?? this.id,
      textEs: textEs ?? this.textEs,
      textEn: textEn ?? this.textEn,
      reference: reference ?? this.reference,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      verseStart: verseStart ?? this.verseStart,
      verseEnd: verseEnd ?? this.verseEnd,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        textEs,
        textEn,
        reference,
        book,
        chapter,
        verseStart,
        verseEnd,
        category,
        tags,
        isFavorite,
      ];
}
