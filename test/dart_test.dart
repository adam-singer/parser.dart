library dart_test;

import 'package:unittest/unittest.dart';

import 'package:parser/dart.dart';
import 'package:parser/test.dart';

void main() {
  var dart = new DartGrammar();
  group('basic', () {
    test('structure', () {
      expect('library test;', accept(dart));
      expect('library test; void main() { }', accept(dart));
      expect('library test; void main() { print(2 + 3); }', accept(dart));
    });
  });
  group('whitespace', () {
    var whitespaces = dart['whitespace'].star().end();
    test('whitespace', () {
      expect(' ', accept(whitespaces));
      expect('\t', accept(whitespaces));
      expect('\n', accept(whitespaces));
      expect('\r', accept(whitespaces));
      expect('a', isNot(accept(whitespaces)));
    });
    test('single-line comment', () {
      expect('//', accept(whitespaces));
      expect('// foo', accept(whitespaces));
      expect('//\n', accept(whitespaces));
      expect('// foo\n', accept(whitespaces));
    });
    test('single-line documentation', () {
      expect('///', accept(whitespaces));
      expect('/// foo', accept(whitespaces));
      expect('/// \n', accept(whitespaces));
      expect('/// foo\n', accept(whitespaces));
    });
    test('multi-line comment', () {
      expect('/**/', accept(whitespaces));
      expect('/* foo */', accept(whitespaces));
      expect('/* foo \n bar */', accept(whitespaces));
      expect('/* foo ** bar */', accept(whitespaces));
      expect('/* foo * / bar */', accept(whitespaces));
    });
    test('multi-line documentation', () {
      expect('/***/', accept(whitespaces));
      expect('/*******/', accept(whitespaces));
      expect('/** foo */', accept(whitespaces));
      expect('/**\n *\n *\n */', accept(whitespaces));
    });
    test('multi-line nested', () {
      expect('/* outer /* nested */ */', accept(whitespaces));
      expect('/* outer /* nested /* deeply nested */ */ */', accept(whitespaces));
      expect('/* outer /* not closed */', isNot(accept(whitespaces)));
    });
    test('combined', () {
      expect('/**/', accept(whitespaces));
      expect(' /**/', accept(whitespaces));
      expect('/**/ ', accept(whitespaces));
      expect(' /**/ ', accept(whitespaces));
      expect('/**///', accept(whitespaces));
      expect('/**/ //', accept(whitespaces));
      expect(' /**/ //', accept(whitespaces));
    });
  });
  group('child parsers', () {
    test('stringContentDQ', () {
      var parser = dart['stringContentDQ'];
      expect("'hi'", accept(parser));
      expect('hello', accept(parser));
      expect(' whitespace ', accept(parser));
    });
    test('singleLineString', () {
      var parser = dart['singleLineString'];
      expect("'hi'", accept(parser));
      expect('"hi"', accept(parser));
      expect(r"r'$'", accept(parser));
      expect('no quotes', isNot(accept(parser)));
      expect('"missing quote', isNot(accept(parser)));
      expect("'missing quote", isNot(accept(parser)));
    });
  });
  group('offical', () {
    test('identifier', () {
      var parser = dart['identifier'].end();
      expect('foo', accept(parser));
      expect('bar9', accept(parser));
      expect('dollar\$', accept(parser));
      expect('_foo', accept(parser));
      expect('_bar9', accept(parser));
      expect('_dollar\$', accept(parser));
      expect('\$', accept(parser));
      expect(' leadingSpace', accept(parser));
      expect('9', isNot(accept(parser)));
      expect('3foo', isNot(accept(parser)));
      expect('', isNot(accept(parser)));
    });
    test('numeric literal', () {
      var parser = dart['numericLiteral'].end();
      expect('0', accept(parser));
      expect('1984', accept(parser));
      expect(' 1984', accept(parser));
//      expect('0xCAFE', accept(parser));
//      expect('0XCAFE', accept(parser));
//      expect('0xcafe', accept(parser));
//      expect('0Xcafe', accept(parser));
//      expect('0xCaFe', accept(parser));
//      expect('0XCaFe', accept(parser));
      expect('3e4', accept(parser));
      expect('3e-4', accept(parser));
      expect('3E4', accept(parser));
      expect('3E-4', accept(parser));
      expect('3.14E4', accept(parser));
      expect('3.14E-4', accept(parser));
      expect('3.14', accept(parser));
      expect('3e--4', isNot(accept(parser)));
      expect('5.', isNot(accept(parser)));
      expect('CAFE', isNot(accept(parser)));
      expect('0xGHIJ', isNot(accept(parser)));
      expect('-', isNot(accept(parser)));
      expect('', isNot(accept(parser)));
    });
    test('boolean literal', () {
      var parser = dart['booleanLiteral'].end();
      expect('true', accept(parser));
      expect('false', accept(parser));
      expect(' true', accept(parser));
      expect(' false', accept(parser));
      expect('9', isNot(accept(parser)));
      expect('"foo"', isNot(accept(parser)));
      expect("'foo'", isNot(accept(parser)));
      expect('TRUE', isNot(accept(parser)));
      expect('FALSE', isNot(accept(parser)));
      expect('null', isNot(accept(parser)));
      expect('0xCAFE', isNot(accept(parser)));
    });
  });
}
