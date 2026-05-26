import 'dart:async';

/// Event notifier for favorites changes
/// Used to synchronize favorites state between Home and Favorites pages
class FavoritesEventNotifier {
  static final _controller = StreamController<FavoriteEvent>.broadcast();

  /// Stream of favorite events
  static Stream<FavoriteEvent> get stream => _controller.stream;

  /// Notify listeners of a favorite change
  static void notify(int storeId, bool isFavorite) {
    _controller.add(FavoriteEvent(storeId, isFavorite));
  }

  /// Dispose the stream controller (call on app dispose if needed)
  static void dispose() {
    _controller.close();
  }
}

/// Event representing a favorite status change
class FavoriteEvent {
  final int storeId;
  final bool isFavorite;

  FavoriteEvent(this.storeId, this.isFavorite);
}
