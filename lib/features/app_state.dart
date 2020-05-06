part of 'app_bloc.dart';

class AppState extends Equatable {
  final String locale;

  const AppState({
    this.locale
  });

  factory AppState.initial() {
    return AppState(
      locale: ''
    );
  }

  AppState copyWith ({
      String locale
  }) {
    return AppState (
      locale: locale ?? this.locale
    );
  }

  @override
  List<Object> get props => [
    locale
  ];

  @override
  String toString() {
    return '''AppState{
      locale: $locale
    }''';
  }
}