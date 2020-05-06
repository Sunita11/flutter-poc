import 'package:bloc/bloc.dart';
import 'dart:async';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  @override
  AppState get initialState => AppState.initial();

  @override
  void onTransition(Transition<AppEvent, AppState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if(event is LocaleChanged) {
      yield state.copyWith(
        locale: event.locale
      );
    }
  }
}