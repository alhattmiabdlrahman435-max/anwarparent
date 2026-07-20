// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Finance)
final financeProvider = FinanceProvider._();

final class FinanceProvider
    extends $AsyncNotifierProvider<Finance, List<StudentFinanceSummary>> {
  FinanceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'financeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$financeHash();

  @$internal
  @override
  Finance create() => Finance();
}

String _$financeHash() => r'95d89068ecadfe1cba3b5b947055c05eeb98bf68';

abstract class _$Finance extends $AsyncNotifier<List<StudentFinanceSummary>> {
  FutureOr<List<StudentFinanceSummary>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<StudentFinanceSummary>>,
              List<StudentFinanceSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<StudentFinanceSummary>>,
                List<StudentFinanceSummary>
              >,
              AsyncValue<List<StudentFinanceSummary>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
