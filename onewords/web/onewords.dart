import 'dart:html';
import 'dart:convert';

void main() {
  var game = new OneWordGame(querySelector("#next-word"));
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
  Element wordElt;
  Element scoreElt;
  int score = 0;
  int currentWord = -1;
  double msTimeout;
  double msLast = 0.0;
  
  var special = new RegExp(r'[one]');
  
  OneWordGame(this.wordElt) {
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
    onFrame(0.0);
  }
  
  void nextWord() {
    currentWord++;
    msTimeout = msLast + 1500;
    wordElt.text = obfuscate(words[currentWord]);
    updateScore(0);
    print("Next word: ${words[currentWord]}.");
  }
  
  Future<num> onFrame(double ms) {
    msLast = ms;
    if (ms >= msTimeout) {
      nextWord();
    }
      
    window.animationFrame.then(onFrame);
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