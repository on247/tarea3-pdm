import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/home_bloc.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc _homeBloc = HomeBloc();
  void _menuItemSelected(HomeEvent event) {
    _homeBloc.add(event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users list"),
        actions: <Widget>[
          PopupMenuButton<HomeEvent>(
              icon: Icon(Icons.format_list_numbered),
              onSelected: _menuItemSelected,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    child: Text("Mostrar pares"),
                    value: FilterUsersEvent(filterEven: true),
                  ),
                  PopupMenuItem(
                    child: Text("Mostrar impares"),
                    value: FilterUsersEvent(filterEven: false),
                  ),
                  PopupMenuItem(
                    child: Text("Mostrar todos"),
                    value: GetAllUsersEvent(),
                  ),
                ];
              })
        ],
      ),
      body: BlocProvider(
        create: (context) => _homeBloc..add(GetAllUsersEvent()),
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            // para mostrar dialogos o snackbars
            if (state is ErrorState) {
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text("Error: ${state.error}")),
                );
            }
          },
          builder: (context, state) {
            if (state is ShowUsersState) {
              return RefreshIndicator(
                child: ListView.separated(
                  itemCount: state.usersList.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(thickness: 2.0),
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(state.usersList[index].name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.usersList[index].company.name),
                          Text(state.usersList[index].address.street),
                          Text(state.usersList[index].phone),
                        ],
                      ),
                    );
                  },
                ),
                onRefresh: () async {
                  BlocProvider.of<HomeBloc>(context).add(GetAllUsersEvent());
                },
              );
            } else if (state is LoadingState) {
              return Center(child: CircularProgressIndicator());
            }
            return Center(
              child: MaterialButton(
                onPressed: () {
                  BlocProvider.of<HomeBloc>(context).add(GetAllUsersEvent());
                },
                child: Text("Cargar de nuevo"),
              ),
            );
          },
        ),
      ),
    );
  }
}
