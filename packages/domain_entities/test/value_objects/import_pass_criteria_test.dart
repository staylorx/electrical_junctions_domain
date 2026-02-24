import 'package:electrical_junctions_entities/index.dart';
import 'package:shouldly/shouldly.dart';
import 'package:test/test.dart';

void main() {
  group('ImportPassCriteria', () {
    group('noErrors (default)', () {
      test('passes when there are no issues', () {
        ImportPassCriteria.noErrors.passes([]).should.beTrue();
      });

      test('passes when there are only warnings', () {
        final issues = [
          const ValidationIssue(
            severity: ValidationSeverity.warning,
            message: 'duplicate name',
          ),
          const ValidationIssue(
            severity: ValidationSeverity.warning,
            message: 'unknown key',
          ),
        ];
        ImportPassCriteria.noErrors.passes(issues).should.beTrue();
      });

      test('fails when there is one error', () {
        final issues = [
          const ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'missing field',
          ),
        ];
        ImportPassCriteria.noErrors.passes(issues).should.beFalse();
      });

      test('fails when there are errors mixed with warnings', () {
        final issues = [
          const ValidationIssue(
            severity: ValidationSeverity.warning,
            message: 'duplicate name',
          ),
          const ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'missing field',
          ),
        ];
        ImportPassCriteria.noErrors.passes(issues).should.beFalse();
      });
    });

    group('strict', () {
      test('passes when there are no issues', () {
        ImportPassCriteria.strict.passes([]).should.beTrue();
      });

      test('fails when there is a warning', () {
        final issues = [
          const ValidationIssue(
            severity: ValidationSeverity.warning,
            message: 'duplicate name',
          ),
        ];
        ImportPassCriteria.strict.passes(issues).should.beFalse();
      });

      test('fails when there is an error', () {
        final issues = [
          const ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'missing field',
          ),
        ];
        ImportPassCriteria.strict.passes(issues).should.beFalse();
      });
    });

    group('custom criteria', () {
      test('allows up to maxErrors errors', () {
        final criteria = ImportPassCriteria(maxErrors: 2);
        final twoErrors = [
          const ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'error 1',
          ),
          const ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'error 2',
          ),
        ];
        criteria.passes(twoErrors).should.beTrue();

        final threeErrors = [
          ...twoErrors,
          const ValidationIssue(
            severity: ValidationSeverity.error,
            message: 'error 3',
          ),
        ];
        criteria.passes(threeErrors).should.beFalse();
      });

      test('disallows warnings when allowWarnings is false', () {
        final criteria = ImportPassCriteria(allowWarnings: false, maxErrors: 5);
        final warningOnly = [
          const ValidationIssue(
            severity: ValidationSeverity.warning,
            message: 'warning',
          ),
        ];
        criteria.passes(warningOnly).should.beFalse();
      });

      test('allows warnings when allowWarnings is true', () {
        final criteria = ImportPassCriteria(allowWarnings: true, maxErrors: 0);
        final warningOnly = [
          const ValidationIssue(
            severity: ValidationSeverity.warning,
            message: 'warning',
          ),
        ];
        criteria.passes(warningOnly).should.beTrue();
      });

      test('combines maxErrors and allowWarnings correctly', () {
        final criteria = ImportPassCriteria(allowWarnings: false, maxErrors: 1);

        // 1 error, no warnings → passes
        criteria
            .passes([
              const ValidationIssue(
                severity: ValidationSeverity.error,
                message: 'error',
              ),
            ])
            .should
            .beTrue();

        // 1 error + 1 warning → fails (warnings not allowed)
        criteria
            .passes([
              const ValidationIssue(
                severity: ValidationSeverity.error,
                message: 'error',
              ),
              const ValidationIssue(
                severity: ValidationSeverity.warning,
                message: 'warning',
              ),
            ])
            .should
            .beFalse();

        // 2 errors → fails (exceeds maxErrors)
        criteria
            .passes([
              const ValidationIssue(
                severity: ValidationSeverity.error,
                message: 'error 1',
              ),
              const ValidationIssue(
                severity: ValidationSeverity.error,
                message: 'error 2',
              ),
            ])
            .should
            .beFalse();
      });
    });
  });
}
