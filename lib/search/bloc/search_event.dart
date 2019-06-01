import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  SearchEvent([List props = const []]) : super(props);
}

class FetchInitial extends SearchEvent {
  @override
  String toString() => 'FetchInitial';
}

class TextChanged extends SearchEvent {
  final String text;

  TextChanged({this.text}) : super([text]);

  @override
  String toString() => 'TextChanged { text: $text }';
}
