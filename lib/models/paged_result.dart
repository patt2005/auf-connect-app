// This model mirrors your C# PagedResult<T> class
class PagedResult<T> {
  final List<T> data;
  final int pageNumber;
  final int pageSize;
  final int totalCount;

  PagedResult({
    required this.data,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResult<T>(
      data: (json['data'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalCount': totalCount,
    };
  }

  // Computed properties
  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasNextPage => pageNumber < totalPages;
  bool get hasPreviousPage => pageNumber > 1;
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
}