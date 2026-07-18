// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClassSchedules)
final classSchedulesProvider = ClassSchedulesProvider._();

final class ClassSchedulesProvider
    extends $NotifierProvider<ClassSchedules, List<ClassSchedule>> {
  ClassSchedulesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'classSchedulesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$classSchedulesHash();

  @$internal
  @override
  ClassSchedules create() => ClassSchedules();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ClassSchedule> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ClassSchedule>>(value),
    );
  }
}

String _$classSchedulesHash() => r'2f8801c75648a7285b126e05ddb3e1ce7886660d';

abstract class _$ClassSchedules extends $Notifier<List<ClassSchedule>> {
  List<ClassSchedule> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<ClassSchedule>, List<ClassSchedule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ClassSchedule>, List<ClassSchedule>>,
              List<ClassSchedule>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
