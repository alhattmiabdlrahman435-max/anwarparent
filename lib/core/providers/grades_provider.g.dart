// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grades_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Grades)
final gradesProvider = GradesProvider._();

final class GradesProvider
    extends $NotifierProvider<Grades, List<SubjectGrade>> {
  GradesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gradesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gradesHash();

  @$internal
  @override
  Grades create() => Grades();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SubjectGrade> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SubjectGrade>>(value),
    );
  }
}

String _$gradesHash() => r'9212b2898ed00dcd1995776b6e81f59ba2c43f05';

abstract class _$Grades extends $Notifier<List<SubjectGrade>> {
  List<SubjectGrade> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<SubjectGrade>, List<SubjectGrade>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SubjectGrade>, List<SubjectGrade>>,
              List<SubjectGrade>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
