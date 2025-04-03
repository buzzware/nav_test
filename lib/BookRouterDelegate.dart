import 'package:flutter/material.dart';

import 'Book.dart';
import 'BookDetailsPage.dart';
import 'BookRoutePath.dart';
import 'BooksListScreen.dart';
import 'UnknownScreen.dart';

class BookRouterDelegate extends RouterDelegate<BookRoutePath> with ChangeNotifier, PopNavigatorRouterDelegateMixin<BookRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;

  Book? _selectedBook;
  bool show404 = false;

  List<Book> books = [
    Book('Left Hand of Darkness', 'Ursula K. Le Guin'),
    Book('Too Like the Lightning', 'Ada Palmer'),
    Book('Kindred', 'Octavia E. Butler'),
  ];

  BookRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  BookRoutePath get currentConfiguration {
    print("currentConfiguration");
    if (show404) {
      return BookRoutePath.unknown();
    }
    return _selectedBook == null
        ? BookRoutePath.home()
        : BookRoutePath.details(books.indexOf(_selectedBook!));
  }

  @override
  Widget build(BuildContext context) {
    print("build");
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('BooksListPage'),
          child: BooksListScreen(
            books: books,
            onTapped: _handleBookTapped,
          ),
        ),
        if (show404)
          MaterialPage(key: ValueKey('UnknownPage'), child: UnknownScreen())
        else if (_selectedBook != null)
          BookDetailsPage(book: _selectedBook!)
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        // Update the list of pages by setting _selectedBook to null
        _selectedBook = null;
        show404 = false;
        notifyListeners();

        return true;
      },
    );
  }

  @override
  Future<void> setInitialRoutePath(BookRoutePath configuration) {
    print("setInitialRoutePath ${configuration.toString()}");
    return super.setInitialRoutePath(configuration);
  }

  @override
  Future<void> setRestoredRoutePath(BookRoutePath configuration) {
    print("setRestoredRoutePath ${configuration.toString()}");
    return super.setRestoredRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(BookRoutePath path) async {
    print("setNewRoutePath ${path.toString()}");
    if (path.isUnknown) {
      _selectedBook = null;
      show404 = true;
      return;
    }

    if (path.isDetailsPage) {
      if (path.id! < 0 || path.id! > books.length - 1) {
        show404 = true;
        return;
      }

      _selectedBook = books[path.id!];
    } else {
      _selectedBook = null;
    }

    show404 = false;
  }

  void _handleBookTapped(Book book) {
    _selectedBook = book;
    notifyListeners();
  }
}
