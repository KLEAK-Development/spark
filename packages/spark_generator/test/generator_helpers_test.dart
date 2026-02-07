import 'package:spark_generator/src/generator_helpers.dart';
import 'package:test/test.dart';

void main() {
  group('parsePathParams', () {
    test('parses colon-style parameters', () {
      expect(parsePathParams('/users/:id'), ['id']);
    });

    test('parses bracket-style parameters', () {
      expect(parsePathParams('/users/{id}'), ['id']);
    });

    test('parses multiple colon-style parameters', () {
      expect(parsePathParams('/users/:userId/posts/:postId'), [
        'userId',
        'postId',
      ]);
    });

    test('parses multiple bracket-style parameters', () {
      expect(parsePathParams('/users/{userId}/posts/{postId}'), [
        'userId',
        'postId',
      ]);
    });

    test('parses mixed colon and bracket parameters', () {
      final params = parsePathParams('/users/:id/comments/{commentId}');
      expect(params, contains('id'));
      expect(params, contains('commentId'));
      expect(params, hasLength(2));
    });

    test('returns empty list for path with no parameters', () {
      expect(parsePathParams('/users/all'), isEmpty);
    });

    test('returns empty list for root path', () {
      expect(parsePathParams('/'), isEmpty);
    });

    test('handles parameter at the end of path', () {
      expect(parsePathParams('/api/v1/items/:id'), ['id']);
    });

    test('handles single segment parameter', () {
      expect(parsePathParams('/:slug'), ['slug']);
    });

    test('handles alphanumeric parameter names', () {
      expect(parsePathParams('/item/:item2Id'), ['item2Id']);
    });
  });

  group('convertToShelfPath', () {
    test('converts colon-style to angle-bracket style', () {
      expect(convertToShelfPath('/users/:id'), '/users/<id>');
    });

    test('converts bracket-style to angle-bracket style', () {
      expect(convertToShelfPath('/users/{id}'), '/users/<id>');
    });

    test('converts multiple colon parameters', () {
      expect(
        convertToShelfPath('/users/:userId/posts/:postId'),
        '/users/<userId>/posts/<postId>',
      );
    });

    test('converts multiple bracket parameters', () {
      expect(
        convertToShelfPath('/users/{userId}/posts/{postId}'),
        '/users/<userId>/posts/<postId>',
      );
    });

    test('converts mixed parameter styles', () {
      expect(
        convertToShelfPath('/users/:id/comments/{commentId}'),
        '/users/<id>/comments/<commentId>',
      );
    });

    test('leaves path without parameters unchanged', () {
      expect(convertToShelfPath('/users/all'), '/users/all');
    });

    test('leaves root path unchanged', () {
      expect(convertToShelfPath('/'), '/');
    });

    test('handles trailing slash', () {
      expect(convertToShelfPath('/users/:id/'), '/users/<id>/');
    });
  });
}
