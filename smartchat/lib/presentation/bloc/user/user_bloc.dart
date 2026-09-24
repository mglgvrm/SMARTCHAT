import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartchat/data/models/UserCardResponse.dart';
import 'package:smartchat/domain/usecases/GetChatableUsersUseCase.dart';



part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {

  final GetChatableUsersUseCase getChatableUsersUseCase;

  UserBloc({
    required this.getChatableUsersUseCase,
  }) : super(UserInitial()) {

    on<GetChatableUsersEvent>(_getChatableUsers);
  }

  Future<void> _getChatableUsers(
      GetChatableUsersEvent event,
      Emitter<UserState> emit,
      ) async {

    emit(UserLoading());

    try {

      final users =
      await getChatableUsersUseCase();

      emit(
        UserLoaded(users),
      );

    } catch (e) {

      emit(
        UserError(e.toString()),
      );
    }
  }
}