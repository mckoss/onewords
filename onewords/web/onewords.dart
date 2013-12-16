import 'dart:html';
import 'dart:convert';
import 'dart:async';

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
  Element bodyElt;
  Element wordElt;
  Element scoreElt;
  Element clockElt;
  Element buttonElt;
  int score = 0;
  int currentWord = -1;
  double msWordTimeout;
  double msNow = 0.0;
  double msGameOver;
  var modeHandler;
  String missingLetters;
  
  static const SECS = 1000;
  static const msGameTime = 60 * SECS;
  
  var special = new RegExp(r'[one]');
  
  OneWordGame() {
    wordElt = querySelector('#next-word');
    scoreElt = querySelector('#score');
    clockElt = querySelector('#clock');
    buttonElt = querySelector('button');
    bodyElt = querySelector('body');
    
    buttonElt.onClick.listen(onStart);
    window.onKeyUp.listen(onKey);
    
    HttpRequest.getString("onewords.json").then(getWords);
    onFrame(0.0);
  }
  
  void getWords(String jsonString) {
    words = JSON.decode(jsonString);
    bodyElt.classes.add('ready');
  }
  
  void onStart(Event e) {
    currentWord = -1;
    nextWord();
    modeHandler = runningMode;
    setMode('running');
    msGameOver = msNow + msGameTime;
  }
  
  void setMode(String mode) {
    bodyElt.classes
    ..clear()
    ..add(mode);
    switch (mode) {
      case 'running':
        modeHandler = runningMode;
        break;
      default:
        modeHandler = null;
    }
  }
  
  void nextWord() {
    if (currentWord == words.length - 1) {
      setMode('ready');
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
    if (msNow > msGameOver) {
      setMode('ready');
      return;
    }
    clockElt.text = ((msGameOver - msNow) / 1000).floor().toString();
    if (msNow >= msWordTimeout) {
      nextWord();
    }
  }
  
  void onKey(KeyboardEvent e) {
    if (missingLetters == null || missingLetters.length == 0 ||
        e.keyCode < 64 || e.keyCode > 64 + 25) {
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