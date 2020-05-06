part of 'app_bloc.dart';


abstract class AppEvent extends Equatable {
 const AppEvent();

 @override
  List<Object> get props => [];
}

class LocaleChanged extends AppEvent {
  final String locale;

  const LocaleChanged({ this.locale});

  @override
  List<Object> get props => [locale];

  @override
  String toString() => 'LocaleChanged {locale: $locale}';
}
