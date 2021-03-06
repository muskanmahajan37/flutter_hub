import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:github_repository/github_repository.dart';
import 'package:flutter_hub/github_search_bloc/bloc.dart';
import 'package:flutter_hub/components/components.dart';

class ProfileSearch extends StatefulWidget {
  @override
  _ProfileSearchState createState() => _ProfileSearchState();
}

class _ProfileSearchState extends State<ProfileSearch>
    with AutomaticKeepAliveClientMixin {
  GithubSearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    _searchBloc = BlocProvider.of<GithubSearchBloc>(context);
    _searchBloc.dispatch(FetchInitialProfiles());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: <Widget>[
        SearchBar(
          hintText: 'Search for Flutter developer profiles',
          onChanged: (text) {
            _searchBloc.dispatch(
              ProfileTextChanged(
                text: text,
              ),
            );
          },
          onClear: () {
            _searchBloc.dispatch(ProfileTextChanged(text: ''));
          },
        ),
        _SearchBody()
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GithubSearchEvent, GithubSearchState>(
      bloc: BlocProvider.of<GithubSearchBloc>(context),
      builder: (BuildContext context, GithubSearchState state) {
        if (state is SearchStateLoading) {
          return CircularProgressIndicator();
        }
        if (state is SearchStateError) {
          return Text(state.error);
        }
        if (state is SearchStateSuccess) {
          return state.items.isEmpty
              ? Text('No Results')
              : Expanded(child: _SearchResults(items: state.items));
        }
      },
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<SearchResultItem> items;

  const _SearchResults({Key key, this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return _SearchResultItem(item: items[index]);
      },
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final SearchResultItem item;

  const _SearchResultItem({Key key, @required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Image.network(item.owner.avatarUrl),
      ),
      title: Text(
        item.owner.login,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      onTap: () async {
        if (await canLaunch(item.owner.htmlUrl)) {
          await launch(item.owner.htmlUrl);
        }
      },
    );
  }
}
