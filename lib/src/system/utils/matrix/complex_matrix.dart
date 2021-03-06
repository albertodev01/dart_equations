import 'package:equations/equations.dart';

/// A simple Dart implementation of an `m x n` matrix whose data type is [double].
///
/// ```dart
/// final matrix = ComplexMatrix(
///   rowCount: 3,
///   columnCount: 4,
/// );
/// ```
///
/// By default, the cells of a matrix are initialized with all zeroes. You can
/// access elements of the matrix very conveniently with the following syntax:
///
/// ```dart
/// final matrix = ComplexMatrix(
///   rowCount: 6,
///   columnCount: 6,
/// );
///
/// final value = matrix(2, 3);
/// final value = matrix.itemAt(2, 3);
/// ```
///
/// Both versions return the same value but the first one is of course less
/// verbose and you should prefer it. In the example, we're retrieving the value
/// of the element at position `(1, 3)` in the matrix.
class ComplexMatrix extends Matrix<Complex> {
  /// Creates a new `N x M` matrix where [rows] is `N` and [columns] is `M`. The
  /// matrix is filled with zeroes.
  ///
  /// If [identity] is set to `true` (by default it's `false`) then the matrix
  /// is initialized with all zeroes **and** the diagonal is filled with ones.
  ComplexMatrix({
    required int rows,
    required int columns,
    bool identity = false,
  }) : super(
          rows: rows,
          columns: columns,
          identity: identity,
          defaultValue: Complex.zero(),
          identityOneValue: Complex.fromReal(1),
        );

  /// Creates a new `N x M` matrix where [rows] is `N` and [columns] is `M`. The
  /// matrix is filled with values from [data].
  ComplexMatrix.fromData({
    required int rows,
    required int columns,
    required List<List<Complex>> data,
  }) : super.fromData(
          rows: rows,
          columns: columns,
          data: data,
        );

  /// Creates a new `N x M` matrix where [rows] is `N` and [columns] is `M`. The
  /// matrix is filled with values from [data].
  ///
  /// The source matrix is expressed as an array whose size must **exactly** be
  /// `N` * `M`.
  ComplexMatrix.fromFlattenedData({
    required int rows,
    required int columns,
    required List<Complex> data,
  }) : super.fromFlattenedData(
          rows: rows,
          columns: columns,
          data: data,
        );

  /// Returns the sum of two matrices.
  @override
  Matrix<Complex> operator +(Matrix<Complex> other) {
    if ((rowCount != other.rowCount) || (columnCount != other.columnCount)) {
      throw const MatrixException("Matrices shapes mismatch! The column count "
          "of the source matrix must match the row count of the other.");
    }

    // Performing the sum
    final flatMatrix = List.generate(
        rowCount * columnCount, (_) => Complex.zero(),
        growable: false);
    final setDataAt = (int row, int col, Complex value) =>
        flatMatrix[columnCount * row + col] = value;

    for (var i = 0; i < rowCount; ++i) {
      for (var j = 0; j < columnCount; ++j) {
        setDataAt(i, j, this(i, j) + other(i, j));
      }
    }

    // Building the new matrix
    return ComplexMatrix.fromFlattenedData(
      rows: rowCount,
      columns: columnCount,
      data: flatMatrix,
    );
  }

  /// Returns the difference of two matrices.
  @override
  Matrix<Complex> operator -(Matrix<Complex> other) {
    if (columnCount != other.rowCount) {
      throw const MatrixException("Matrices shapes mismatch! The column count "
          "of the source matrix must match the row count of the other.");
    }

    // Performing the difference
    final flatMatrix = List.generate(
        rowCount * columnCount, (_) => Complex.zero(),
        growable: false);
    final setDataAt = (int row, int col, Complex value) =>
        flatMatrix[columnCount * row + col] = value;

    for (var i = 0; i < rowCount; ++i) {
      for (var j = 0; j < columnCount; ++j) {
        setDataAt(i, j, this(i, j) - other(i, j));
      }
    }

    // Building the new matrix
    return ComplexMatrix.fromFlattenedData(
      rows: rowCount,
      columns: columnCount,
      data: flatMatrix,
    );
  }

  /// Returns the sum of two matrices.
  @override
  Matrix<Complex> operator *(Matrix<Complex> other) {
    if (columnCount != other.rowCount) {
      throw const MatrixException("Matrices shapes mismatch! The column count "
          "of the source matrix must match the row count of the other.");
    }

    // Performing the product
    final flatMatrix = List.generate(
        rowCount * columnCount, (_) => Complex.zero(),
        growable: false);
    final setDataAt = (int row, int col, Complex value) =>
        flatMatrix[columnCount * row + col] = value;

    // Performing the multiplication
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < other.columnCount; j++) {
        var sum = Complex.zero();
        for (var k = 0; k < rowCount; k++) {
          sum += (this(i, k) * other(k, j));
        }
        setDataAt(i, j, sum);
      }
    }

    // Building the new matrix
    return ComplexMatrix.fromFlattenedData(
      rows: rowCount,
      columns: columnCount,
      data: flatMatrix,
    );
  }

  /// Returns the division of two matrices in `O(n)` complexity.
  @override
  Matrix<Complex> operator /(Matrix<Complex> other) {
    if (columnCount != other.rowCount) {
      throw const MatrixException("Matrices shapes mismatch! The column count "
          "of the source matrix must match the row count of the other.");
    }

    // Performing the division
    final flatMatrix = List.generate(
        rowCount * columnCount, (_) => Complex.zero(),
        growable: false);
    final setDataAt = (int row, int col, Complex value) =>
        flatMatrix[columnCount * row + col] = value;

    // Performing the division
    for (var i = 0; i < rowCount; ++i) {
      for (var j = 0; j < columnCount; ++j) {
        setDataAt(i, j, this(i, j) / other(i, j));
      }
    }

    // Building the new matrix
    return ComplexMatrix.fromFlattenedData(
      rows: rowCount,
      columns: columnCount,
      data: flatMatrix,
    );
  }

  /// The determinant can only be computed if the matrix is **square**, meaning
  /// that it must have the same number of columns and rows.
  ///
  /// The determinant of a 1*1, 2*2, 3*3 or 4*4 matrix is efficiently computed.
  /// Note that for all the other dimensions, the algorithm is exponentially
  /// slower.
  @override
  Complex determinant() => _computeDeterminant(this);

  /// Factors the matrix as the product of a lower triangular matrix `L` and
  /// an upper triangular matrix `U`. The matrix **must** be square.
  ///
  /// The returned list contains `L` at index 0 and `U` at index 1.
  @override
  List<ComplexMatrix> luDecomposition() {
    // Making sure that the matrix is squared
    if (!isSquareMatrix) {
      throw MatrixException(
          "LU decomposition only works with square matrices!");
    }

    // Creating L and U matrices
    final L = List<Complex>.generate(
        rowCount * columnCount, (_) => Complex.zero(),
        growable: false);
    final U = List<Complex>.generate(
        rowCount * columnCount, (_) => Complex.zero(),
        growable: false);

    final getDataAt = (List<Complex> source, int row, int col) =>
        source[columnCount * row + col];
    final setDataAt = (List<Complex> source, int row, int col, Complex value) =>
        source[columnCount * row + col] = value;

    // Computing L and U
    for (var i = 0; i < rowCount; ++i) {
      for (var k = i; k < rowCount; k++) {
        // Summation of L(i, j) * U(j, k)
        var sum = Complex.zero();
        for (var j = 0; j < i; j++) {
          sum += (getDataAt(L, i, j) * getDataAt(U, j, k));
        }

        // Evaluating U(i, k)
        setDataAt(U, i, k, this(i, k) - sum);
      }

      // Lower Triangular
      for (var k = i; k < rowCount; k++) {
        if (i == k) {
          setDataAt(L, i, i, Complex.fromReal(1));
        } else {
          // Summation of L(k, j) * U(j, i)
          var sum = Complex.zero();
          for (var j = 0; j < i; j++) {
            sum += (getDataAt(L, k, j) * getDataAt(U, j, i));
          }

          // Evaluating L(k, i)
          setDataAt(L, k, i, (this(k, i) - sum) / getDataAt(U, i, i));
        }
      }
    }

    return [
      ComplexMatrix.fromFlattenedData(
        rows: rowCount,
        columns: rowCount,
        data: L,
      ),
      ComplexMatrix.fromFlattenedData(
        rows: rowCount,
        columns: rowCount,
        data: U,
      ),
    ];
  }

  /// Uses the the Cholesky decomposition algorithm to factor the matrix into
  /// the product of a lower triangular matrix and its conjugate transpose. In
  /// particular, this method returns the `L` and `L`<sup>T</sup> matrices of the
  ///
  ///  - A = L x L<sup>T</sup>
  ///
  /// relation. The algorithm might fail in case the square root of a negative
  /// number were encountered.
  ///
  /// The returned list contains `L` at index 0 and `L`<sup>T</sup> at index 1.
  @override
  List<ComplexMatrix> choleskyDecomposition() {
    // Making sure that the matrix is squared
    if (!isSquareMatrix) {
      throw MatrixException(
          "LU decomposition only works with square matrices!");
    }

    // Exit immediately because if [0,0] is a negative number, the algorithm
    // cannot even start since the square root of a negative number in R is not
    // allowed.
    if (this(0, 0) <= Complex.zero()) {
      throw const SystemSolverException("The matrix is not positive-definite.");
    }

    // Creating L and Lt matrices
    final L = List<Complex>.generate(
        rowCount * columnCount, (_) => Complex.zero(),
        growable: false);
    final transpL = List<Complex>.generate(
        rowCount * columnCount, (_) => Complex.zero(),
        growable: false);

    final getDataAt = (List<Complex> source, int row, int col) =>
        source[columnCount * row + col];
    final setDataAt = (List<Complex> source, int row, int col, Complex value) =>
        source[columnCount * row + col] = value;

    // Computing the L matrix so that A = L * Lt (where 'Lt' is L transposed)
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j <= i; j++) {
        var sum = Complex.zero();
        if (j == i) {
          for (var k = 0; k < j; k++) {
            sum += getDataAt(L, j, k) * getDataAt(L, j, k);
          }
          setDataAt(L, j, j, (this(i, j) - sum).sqrt());
        } else {
          for (var k = 0; k < j; k++) {
            sum += getDataAt(L, i, k) * getDataAt(L, j, k);
          }
          setDataAt(L, i, j, (this(i, j) - sum) / getDataAt(L, j, j));
        }
      }
    }

    // Computing Lt, the transposed version of L
    for (var i = 0; i < rowCount; i++) {
      for (var j = 0; j < rowCount; j++) {
        setDataAt(transpL, i, j, getDataAt(L, j, i));
      }
    }

    return [
      ComplexMatrix.fromFlattenedData(
        rows: rowCount,
        columns: columnCount,
        data: L,
      ),
      ComplexMatrix.fromFlattenedData(
        rows: rowCount,
        columns: columnCount,
        data: transpL,
      )
    ];
  }

  /// Computes the determinant of a 2x2 matrix
  Complex _compute2x2Determinant(ComplexMatrix source) {
    return source.flattenData[0] * source.flattenData[3] -
        source.flattenData[1] * source.flattenData[2];
  }

  /// Computes the determinant of a 3x3 matrix
  Complex _compute3x3Determinant(ComplexMatrix source) {
    final x = source.flattenData[0] *
        ((source.flattenData[4] * source.flattenData[8]) -
            (source.flattenData[5] * source.flattenData[7]));
    final y = source.flattenData[1] *
        ((source.flattenData[3] * source.flattenData[8]) -
            (source.flattenData[5] * source.flattenData[6]));
    final z = source.flattenData[2] *
        ((source.flattenData[3] * source.flattenData[7]) -
            (source.flattenData[4] * source.flattenData[6]));

    return x - y + z;
  }

  /// Computes the determinant of a 4x4 matrix
  Complex _compute4x4Determinant(ComplexMatrix source) {
    final det2_01_01 = source.flattenData[0] * source.flattenData[5] -
        source.flattenData[1] * source.flattenData[4];
    final det2_01_02 = source.flattenData[0] * source.flattenData[6] -
        source.flattenData[2] * source.flattenData[4];
    final det2_01_03 = source.flattenData[0] * source.flattenData[7] -
        source.flattenData[3] * source.flattenData[4];
    final det2_01_12 = source.flattenData[1] * source.flattenData[6] -
        source.flattenData[2] * source.flattenData[5];
    final det2_01_13 = source.flattenData[1] * source.flattenData[7] -
        source.flattenData[3] * source.flattenData[5];
    final det2_01_23 = source.flattenData[2] * source.flattenData[7] -
        source.flattenData[3] * source.flattenData[6];

    final det3_201_012 = source.flattenData[8] * det2_01_12 -
        source.flattenData[9] * det2_01_02 +
        source.flattenData[10] * det2_01_01;
    final det3_201_013 = source.flattenData[8] * det2_01_13 -
        source.flattenData[9] * det2_01_03 +
        source.flattenData[11] * det2_01_01;
    final det3_201_023 = source.flattenData[8] * det2_01_23 -
        source.flattenData[10] * det2_01_03 +
        source.flattenData[11] * det2_01_02;
    final det3_201_123 = source.flattenData[9] * det2_01_23 -
        source.flattenData[10] * det2_01_13 +
        source.flattenData[11] * det2_01_12;

    return -det3_201_123 * source.flattenData[12] +
        det3_201_023 * source.flattenData[13] -
        det3_201_013 * source.flattenData[14] +
        det3_201_012 * source.flattenData[15];
  }

  /// Recursively computes the determinant of a matrix. In case of 1x1, 2x2,
  /// 3x3 and 4x4 matrices, the calculations are "manually" done.
  Complex _computeDeterminant(ComplexMatrix source) {
    // Computing the determinant only if the matrix is square
    if (source.rowCount != source.columnCount) {
      throw const MatrixException("Can't compute the determinant of this "
          "matrix because it's not square.");
    }

    // In case there were an 1x1 matrix, just return the value
    if (source.rowCount * source.columnCount == 1) {
      return source.flattenData[0];
    }

    // For efficiency, manually computing a 2x2 matrix
    if (source.rowCount * source.columnCount == 4) {
      return _compute2x2Determinant(source);
    }

    // For efficiency, manually computing a 3x3 matrix
    if (source.rowCount * source.columnCount == 9) {
      return _compute3x3Determinant(source);
    }

    // For efficiency, manually computing a 4x4 matrix
    if (source.rowCount * source.columnCount == 16) {
      return _compute4x4Determinant(source);
    }

    // In all the other cases, so when a matrix is 5x5 or bigger, the default
    // determinant computation happens via LU decomposition. Look at this well
    // known relation:
    //
    //  det(A) = det(L x U) = det(L) x det(U)
    //
    // In particular, the determinant of a lower triangular and an upper triangular
    // matrix is the product of the items in the diagonal.
    //
    // For this reason, the computation of the determinant is O(n^3) which is way
    // better than O(n!) from the Leibniz formula or the Laplace transformation!
    final lu = luDecomposition();

    var prodL = Complex(1, 0);
    var prodU = Complex(1, 0);

    // The determinant of L and U is the product of the elements on the diagonal
    for (var i = 0; i < rowCount; ++i) {
      prodL *= lu[0](i, i);
      prodU *= lu[1](i, i);
    }

    return prodL * prodU;
  }
}
