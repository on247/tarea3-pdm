import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:form_get_users_bloc/models/user.dart';
import 'package:http/http.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final _link = "https://jsonplaceholder.typicode.com/users";
  List<User> _savedList;
  List<User> _userList;

  HomeBloc() : super(HomeInitial());

  @override
  Stream<HomeState> mapEventToState(
    HomeEvent event,
  ) async* {
    if (event is GetAllUsersEvent) {
      yield LoadingState();
      await _getAllUsers();
      if (_userList.length > 0)
        yield ShowUsersState(usersList: _userList);
      else
        yield ErrorState(error: "No hay elementos por mostrar");
    } //
    else if (event is FilterUsersEvent) {
      _userList = _savedList;
      if (event.namedProps["filterEven"]) {
        _userList.retainWhere((element) => element.id % 2 == 0);
      } else {
        _userList.retainWhere((element) => element.id % 2 != 0);
      }
      yield ShowUsersState(usersList: _userList);
    } //
    else if (event is RemoveFilterEvent) {
      _userList = _savedList;
      yield ShowUsersState(usersList: _userList);
    } //
  }

  Future _getAllUsers() async {
    try {
      Response response = await get(_link);
      if (response.statusCode == 200) {
        _userList = List();
        List<dynamic> data = jsonDecode(response.body);
        _userList = data.map((element) => User.fromJson(element)).toList();
        _savedList = List<User>.from(_userList);
      }
    } catch (error) {
      print(error.toString());
      _userList = List();
    }
  }
}
