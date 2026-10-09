// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grades_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GradesStatus)
final gradesStatusProvider = GradesStatusProvider._();

final class GradesStatusProvider
    extends $NotifierProvider<GradesStatus, Map<String, dynamic>> {
  GradesStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gradesStatusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gradesStatusHash();

  @$internal
  @override
  GradesStatus create() => GradesStatus();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, dynamic> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, dynamic>>(value),
    );
  }
}

String _$gradesStatusHash() => r'ce6473135182c86f77498bd7e1c8cc0cf307e395';

abstract class _$GradesStatus extends $Notifier<Map<String, dynamic>> {
  Map<String, dynamic> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, dynamic>, Map<String, dynamic>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, dynamic>, Map<String, dynamic>>,
              Map<String, dynamic>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

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

String _$gradesHash() => r'ad2ba19ece79fbdf854a0df4fd27a9a343aa25fd';

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
