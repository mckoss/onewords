import 'package:polymer/polymer.dart';
import 'dart:html';

@CustomTag('hidden-word')
class HiddenWordElement extends PolymerElement {
  @observable List<String> letters;
  String hiddenLetters;
  
  HiddenWordElement.created() : super.created();
  
  void setWord(String word, String hidden) {
    hiddenLetters = hidden;
    letters = toObservable(word.split(""));
  }
}