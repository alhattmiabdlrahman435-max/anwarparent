// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exams_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Exams)
final examsProvider = ExamsProvider._();

final class ExamsProvider extends $NotifierProvider<Exams, List<ExamSchedule>> {
  ExamsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'examsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$examsHash();

  @$internal
  @override
  Exams create() => Exams();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ExamSchedule> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ExamSchedule>>(value),
    );
  }
}

String _$examsHash() => r'5df99a8d99cf4b4d385281207270937f0349ba2f';

abstract class _$Exams extends $Notifier<List<ExamSchedule>> {
  List<ExamSchedule> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<ExamSchedule>, List<ExamSchedule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ExamSchedule>, List<ExamSchedule>>,
              List<ExamSchedule>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
