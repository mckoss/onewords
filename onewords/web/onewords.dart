import 'dart:html';
import 'dart:convert';

void main() {
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
  Element wordElt;
  Element scoreElt;
  int score = 0;
  int currentWord = -1;
  double msWordTimeout;
  double msNow = 0.0;
  var modeHandler;
  String missingLetters;
  
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
    msWordTimeout = msNow + 3000;
    missingLetters = getLetters(words[currentWord], "one");
    wordElt.text = obfuscate(words[currentWord], missingLetters);
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
    if (missingLetters.length == 0 || e.keyCode < 64 || e.keyCode > 64 + 25) {
      return;
    }
    String ch = new String.fromCharCode(e.keyCode).toLowerCase();
    if (!missingLetters.contains(ch)) {
      print("Letter ($ch) not in missing set '$missingLetters'.");
      return;
    }
    
    print("Pressed key '${ch}'");
    if (ch == missingLetters[0]) {
      missingLetters = missingLetters.substring(1);
      updateScore(1);
      wordElt.text = obfuscate(words[currentWord], missingLetters);
    } else {
      updateScore(-1);
    }
  }
  
  void updateScore(int delta) {
    score += delta;
    // Should this be done in the animation frame instead of async?
    scoreElt.text = "$score / ${currentWord * 3}";
  }
  
  String obfuscate(String word, String hidden) {
    var sb = new StringBuffer();
    for (var i = 0; i < word.length; i++) {
      sb.write(hidden.contains(word[i]) ? '_' : word[i]);
    }
    return sb.toString();
  }
  
  String getLetters(word, letters) {
    var sb = new StringBuffer();
    for (var i = 0; i < word.length; i++) {
      if (letters.contains(word[i])) {
        sb.write(word[i]);
      }
    }
    return sb.toString();
  }
}