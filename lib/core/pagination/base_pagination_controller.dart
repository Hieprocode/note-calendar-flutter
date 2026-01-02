import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Base controller cho pagination với Firestore
/// Sử dụng cho bất kỳ list nào cần load more (notifications, bookings, customers, etc.)
abstract class BasePaginationController<T> extends GetxController {
  // Observable variables
  var items = <T>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var hasMore = true.obs;
  
  DocumentSnapshot? _lastDocument;
  final int pageSize;

  BasePaginationController({this.pageSize = 20});

  /// Override method này để implement logic load data
  /// Trả về Map với 'items' và 'lastDocument'
  Future<Map<String, dynamic>> fetchItems({
    DocumentSnapshot? lastDocument,
    int? limit,
  });

  /// Load dữ liệu ban đầu
  Future<void> loadInitialItems() async {
    try {
      isLoading.value = true;
      
      final result = await fetchItems(limit: pageSize);
      
      final fetchedItems = result['items'] as List<T>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;
      
      items.value = fetchedItems;
      hasMore.value = fetchedItems.length >= pageSize;
      
      print("--> [PAGINATION] Loaded ${fetchedItems.length} items");
    } catch (e) {
      print("--> [PAGINATION ERROR] loadInitialItems: $e");
      items.value = [];
      hasMore.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more items khi scroll xuống cuối
  Future<void> loadMoreItems() async {
    if (!hasMore.value || isLoadingMore.value) {
      print("--> [PAGINATION] Skip load more: hasMore=${hasMore.value}, isLoadingMore=${isLoadingMore.value}");
      return;
    }
    
    try {
      isLoadingMore.value = true;
      print("--> [PAGINATION] Loading more items...");
      
      final result = await fetchItems(
        lastDocument: _lastDocument,
        limit: pageSize,
      );
      
      final moreItems = result['items'] as List<T>;
      _lastDocument = result['lastDocument'] as DocumentSnapshot?;
      
      if (moreItems.isNotEmpty) {
        items.addAll(moreItems);
        hasMore.value = moreItems.length >= pageSize;
        print("--> [PAGINATION] Loaded ${moreItems.length} more items. Total: ${items.length}");
      } else {
        hasMore.value = false;
        print("--> [PAGINATION] No more items to load");
      }
    } catch (e) {
      print("--> [PAGINATION ERROR] loadMoreItems: $e");
      hasMore.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Refresh lại toàn bộ danh sách
  Future<void> refreshItems() async {
    _lastDocument = null;
    hasMore.value = true;
    await loadInitialItems();
  }

  /// Clear tất cả data
  void clearItems() {
    items.clear();
    _lastDocument = null;
    hasMore.value = true;
  }
}
