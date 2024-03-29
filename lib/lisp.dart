/**
 * This package contains a simple grammar and evaluator for LISP.
 *
 * The code is reasonably complete to run and evaluate reasonably complex
 * programs from the console and from the web browser.
 */
library parser.lisp;

import 'dart:collection';
import 'package:parser/parser.dart';

part 'src/lisp/cons.dart';
part 'src/lisp/environment.dart';
part 'src/lisp/grammar.dart';
part 'src/lisp/name.dart';
part 'src/lisp/natives.dart';
part 'src/lisp/parser.dart';
part 'src/lisp/standard.dart';

/** The evaluation function. */
dynamic eval(Environment env, dynamic expr) {
  if (expr is Cons) {
    return eval(env, expr.head)(env, expr.tail);
  } else if (expr is Name) {
    return env[expr];
  } else {
    return expr;
  }
}

/** Evaluate a cons of instructions. */
dynamic evalList(Environment env, dynamic expr) {
  var result = null;
  while (expr is Cons) {
    result = eval(env, expr.head);
    expr = expr.tail;
  }
  return result;
}

/** The arguments evaluatation function. */
dynamic evalArguments(Environment env, dynamic args) {
  if (args is Cons) {
    return new Cons(eval(env, args.head), evalArguments(env, args.tail));
  } else {
    return null;
  }
}

/** Reads and evaluates a [script]. */
dynamic evalString(LispParser parser, Environment env, String script) {
  var result = null;
  for (var cell in parser.parse(script).value) {
    result = eval(env, cell);
  }
  return result;
}
