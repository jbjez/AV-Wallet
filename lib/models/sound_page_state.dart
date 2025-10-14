import '../models/catalogue_item.dart';

class SoundPageState {
  final String searchQuery;
  final String? selectedSpeaker;
  final int speakerQuantity;
  final List<Map<String, dynamic>> selectedSpeakers;
  final List<CatalogueItem> searchResults;
  final String? calculationResult;
  final String? selectedCategory;
  final String? selectedBrand;

  const SoundPageState({
    this.searchQuery = '',
    this.selectedSpeaker,
    this.speakerQuantity = 1,
    this.selectedSpeakers = const [],
    this.searchResults = const [],
    this.calculationResult,
    this.selectedCategory,
    this.selectedBrand,
  });

  SoundPageState copyWith({
    String? searchQuery,
    String? selectedSpeaker,
    int? speakerQuantity,
    List<Map<String, dynamic>>? selectedSpeakers,
    List<CatalogueItem>? searchResults,
    String? calculationResult,
    String? selectedCategory,
    String? selectedBrand,
  }) {
    return SoundPageState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSpeaker: selectedSpeaker ?? this.selectedSpeaker,
      speakerQuantity: speakerQuantity ?? this.speakerQuantity,
      selectedSpeakers: selectedSpeakers ?? this.selectedSpeakers,
      searchResults: searchResults ?? this.searchResults,
      calculationResult: calculationResult,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedBrand: selectedBrand ?? this.selectedBrand,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'searchQuery': searchQuery,
      'selectedSpeaker': selectedSpeaker,
      'speakerQuantity': speakerQuantity,
      'selectedSpeakers': selectedSpeakers,
      'searchResults': searchResults.map((item) => item.toJson()).toList(),
      'calculationResult': calculationResult,
      'selectedCategory': selectedCategory,
      'selectedBrand': selectedBrand,
    };
  }

  factory SoundPageState.fromJson(Map<String, dynamic> json) {
    return SoundPageState(
      searchQuery: json['searchQuery'] ?? '',
      selectedSpeaker: json['selectedSpeaker'],
      speakerQuantity: json['speakerQuantity'] ?? 1,
      selectedSpeakers: List<Map<String, dynamic>>.from(json['selectedSpeakers'] ?? []),
      searchResults: (json['searchResults'] as List<dynamic>?)
          ?.map((item) => CatalogueItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      calculationResult: json['calculationResult'],
      selectedCategory: json['selectedCategory'],
      selectedBrand: json['selectedBrand'],
    );
  }
}
