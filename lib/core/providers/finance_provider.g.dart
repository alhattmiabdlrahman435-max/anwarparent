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
    extends $NotifierProvider<Finance, List<StudentFinanceSummary>> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<StudentFinanceSummary> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<StudentFinanceSummary>>(value),
    );
  }
}

String _$financeHash() => r'19df94ddc3bf4807610e40687271ad7937df7910';

abstract class _$Finance extends $Notifier<List<StudentFinanceSummary>> {
  List<StudentFinanceSummary> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<List<StudentFinanceSummary>, List<StudentFinanceSummary>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<StudentFinanceSummary>,
                List<StudentFinanceSummary>
              >,
              List<StudentFinanceSummary>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
