part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
 AuthenticationState();
}

class Unitinitalized extends AuthenticationState {
  @override
  List<Object> get props => [];
}

/* User is new*/
class Unauthenticated extends AuthenticationState {

}

/* User has skip login */
class GuestAuthentication extends AuthenticationState {

}

class Authenticated extends AuthenticationState {

} 

