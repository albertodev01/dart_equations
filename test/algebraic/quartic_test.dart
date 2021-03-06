import 'package:equations/equations.dart';
import 'package:fraction/fraction.dart';
import 'package:test/test.dart';

import '../double_approximation_matcher.dart';

void main() {
  group("Testing 'Quartic' algebraic equations", () {
    test("Making sure that a 'Quartic' object is properly constructed", () {
      final equation = Quartic.realEquation(a: 3, b: 6, d: 2, e: -1);

      // Checking properties
      expect(equation.degree, equals(4));
      expect(
          equation.derivative(),
          Cubic(
              a: Complex.fromReal(12),
              b: Complex.fromReal(18),
              d: Complex.fromReal(2)));
      expect(equation.isRealEquation, isTrue);
      expect(equation.discriminant(), equals(Complex.fromReal(-70848)));
      expect(
          equation.coefficients,
          equals([
            Complex.fromReal(3),
            Complex.fromReal(6),
            Complex.zero(),
            Complex.fromReal(2),
            Complex.fromReal(-1),
          ]));

      // Making sure that coefficients can be accessed via index
      expect(equation[0], equals(Complex.fromReal(3)));
      expect(equation[1], equals(Complex.fromReal(6)));
      expect(equation[2], equals(Complex.zero()));
      expect(equation[3], equals(Complex.fromReal(2)));
      expect(equation[4], equals(Complex.fromReal(-1)));
      expect(() => equation[-1], throwsA(isA<RangeError>()));
      expect(equation.coefficient(4), equals(Complex.fromReal(3)));
      expect(equation.coefficient(3), equals(Complex.fromReal(6)));
      expect(equation.coefficient(2), equals(Complex.zero()));
      expect(equation.coefficient(1), equals(Complex.fromReal(2)));
      expect(equation.coefficient(0), equals(Complex.fromReal(-1)));
      expect(equation.coefficient(5), isNull);

      // Converting to string
      expect(equation.toString(), equals("f(x) = 3x^4 + 6x^3 + 2x + -1"));
      expect(equation.toStringWithFractions(),
          equals("f(x) = 3x^4 + 6x^3 + 2x + -1"));

      // Checking solutions
      final solutions = equation.solutions();
      expect(solutions[0].real, MoreOrLessEquals(-2.173571613806));
      expect(solutions[0].imaginary.round(), isZero);
      expect(solutions[1].real, MoreOrLessEquals(0.349518864775));
      expect(solutions[1].imaginary.round(), isZero);
      expect(solutions[2].real, MoreOrLessEquals(-0.087973625484));
      expect(solutions[2].imaginary, MoreOrLessEquals(0.656527118533));
      expect(solutions[3].real, MoreOrLessEquals(-0.087973625484));
      expect(solutions[3].imaginary, MoreOrLessEquals(-0.656527118533));

      // Evaluation
      final eval = equation.realEvaluateOn(2);
      expect(eval.real.round(), equals(99));
      expect(eval.imaginary.round(), isZero);
    });

    test(
        "Making sure that an exception is thrown if the coeff. of the highest"
        " degree is zero", () {
      expect(() {
        Quartic(
          a: Complex.zero(),
        );
      }, throwsA(isA<AlgebraicException>()));
    });

    test(
        "Making sure that a correct 'Quadratic' instance is created from a "
        "list of 'double' (real) values", () {
      final quartic = Quartic.realEquation(a: -3, d: 8);

      expect(quartic.a, equals(Complex.fromReal(-3)));
      expect(quartic.d, equals(Complex.fromReal(8)));

      // There must be an exception is the first coeff. is zero
      expect(
          () => Quartic.realEquation(a: 0), throwsA(isA<AlgebraicException>()));
    });

    test("Making sure that objects comparison works properly", () {
      final fx = Quartic(
          a: Complex(3, -6),
          b: Complex.fromImaginary(-2),
          c: Complex.fromFraction(Fraction(1, 2), Fraction(1, 5)),
          d: Complex.i(),
          e: Complex.fromReal(9));

      final otherFx = Quartic(
          a: Complex(3, -6),
          b: Complex.fromImaginary(-2),
          c: Complex.fromFraction(Fraction(1, 2), Fraction(1, 5)),
          d: Complex.i(),
          e: Complex.fromReal(9));

      expect(fx, equals(otherFx));
      expect(fx == otherFx, isTrue);
      expect(fx.hashCode, equals(otherFx.hashCode));
    });

    test("Making sure that 'copyWith' clones objects correctly", () {
      final quartic = Quartic.realEquation(c: 5, d: -6);

      // Objects equality
      expect(quartic, equals(quartic.copyWith()));
      expect(
          quartic,
          equals(quartic.copyWith(
            a: Complex.fromReal(1),
            b: Complex.zero(),
            c: Complex.fromReal(5),
            d: Complex.fromReal(-6),
            e: Complex.zero(),
          )));

      // Objects inequality
      expect(quartic == quartic.copyWith(c: Complex.zero()), isFalse);
    });
  });
}
