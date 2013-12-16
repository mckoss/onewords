import 'dart:html';
import 'dart:convert';
import 'hidden-word.dart';
import 'package:polymer/polymer.dart';

void main() {
  initPolymer();
  var game = new OneWordGame();
}

void reverseText(MouseEvent event) {
  var text = querySelector("#sample_text_id").text;
  var buffer = new StringBuffer();
  for (int i = text.length - 1; i >= 0; i--) {
    buffer.write(text[i]);
  }
  querySelector("#sample_text_id").text = buffer.toString();
}

class OneWordGame {
  List<String> words;
  HiddenWordElement wordElt;
  Element scoreElt;
  int score = 0;
  int currentWord = -1;
  double msWordTimeout;
  double msNow = 0.0;
  var modeHandler;
  
  var special = new RegExp(r'[one]');
  
  OneWordGame() {
    wordElt = querySelector("#next-word");
    scoreElt = querySelector("#score");
    
    HttpRequest.getString("onewords.json")
    .then(getWords);
  }
  
  void getWords(String jsonString) {
    words = JSON.decode(jsonString);
    start();
  }
  
  void start() {
    window.onKeyUp.listen(onKey);
    nextWord();
    modeHandler = runningMode;
    onFrame(0.0);
  }
  
  void nextWord() {
    if (currentWord == words.length - 1) {
      modeHandler = null;
      return;
    }
    currentWord++;
    msWordTimeout = msNow + 1000;
    wordElt.setWord(words[currentWord], "one");
    updateScore(0);
    print("Next word: ${words[currentWord]}.");
  }
  
  Future<num> onFrame(double ms) {
    msNow = ms;
    if (modeHandler != null) {
      modeHandler();
    }
    window.animationFrame.then(onFrame);
  }
  
  void runningMode() {
    if (msNow >= msWordTimeout) {
      nextWord();
    }
  }
  
  void onKey(KeyboardEvent e) {
    print("Pressed key ${e.keyCode}");
    updateScore(1);
  }
  
  void updateScore(int delta) {
    score += delta;
    scoreElt.text = "$score / ${currentWord}";
  }
  
  String obfuscate(String word) {
    return word.replaceAll(special, '_');
  }
}