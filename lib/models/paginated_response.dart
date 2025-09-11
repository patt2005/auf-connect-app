class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int pageSize;
  final int totalCount;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'] ?? json['pageNumber'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? json['total'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      'currentPage': currentPage,
      'totalPages': totalPages,
      'pageSize': pageSize,
      'totalCount': totalCount,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
}