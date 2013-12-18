import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

void main() {
  var game = new OneWordGame();
}

class OneWordGame {
  List<String> words;
  Element bodyElt = querySelector('body');
  Element wordElt = querySelector('#next-word');
  Element scoreElt = querySelector('#score');
  Element clockElt = querySelector('#clock');
  Element buttonElt = querySelector('button');
  int score = 0;
  int currentWord = -1;
  double msWordTimeout;
  double msStartWord;
  double msNow = 0.0;
  double msGameOver;
  var modeHandler;
  String missingLetters;
  bool letterError;
  
  static const secs = 1000;
  static const msGameTime = 30 * secs;
  static const msWordTime = 3 * secs;
  static const msFlashTime = 200;
  static const msCognitive = 100;
  
  var special = new RegExp(r'[one]');
  
  OneWordGame() {
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
    score = 0;
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
    msWordTimeout = msNow + msWordTime;
    msStartWord = msNow;
    missingLetters = getLetters(words[currentWord], "one");
    wordElt.classes.clear();
    letterError = false;
    setWord(words[currentWord], missingLetters);
    print("Next word: ${words[currentWord]}.");
    updateScore(0);
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
    int index = missingLetters.indexOf(ch);
    if (index == -1) {
      return;
    }
    print("Pressed key '${ch}'");
    
    if (index != 0 && msNow - msStartWord < msCognitive) {
      print("Filtered mis-type-ahead letter.");
      return;
    }
    
    missingLetters = missingLetters.replaceFirst(ch, '');
    setWord(words[currentWord], missingLetters);
    if (letterError) {
      return;
    }
    
    if (index == 0) {
      if (missingLetters.length == 0) {
        updateScore(1);
        msGameOver += max(0.0, msWordTimeout - msNow);
        msWordTimeout = min(msWordTimeout, msNow + msFlashTime);
      }
      return;
    }
    
    wordElt.classes.add('error');
    letterError = true;
  }
  
  void updateScore(int delta) {
    score += delta;
    // Should this be done in the animation frame instead of async?
    scoreElt.text = "$score / $currentWord";
  }
  
  void setWord(String word, String hidden) {
    var outer = new DivElement();
    for (var i = 0; i < word.length; i++) {
      String ch = word[i];
      if (hidden.contains(ch)) {
        ch = '_';
      }
      bool isSpecial = "one".contains(ch);
      if (isSpecial) {
        var s = new SpanElement();
        s.classes.add('special');
        s.text = ch;
        outer.append(s);
      } else {
        outer.appendText(ch);
      }
    }
    wordElt.children
    ..clear()
    ..add(outer);
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