import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'dart:math';

void main() {
  var game = new OneWordGame();
}

class OneWordGame {
  List<String> words;
  Element _bodyElt = querySelector('body');
  Element _wordElt = querySelector('#next-word');
  Element _scoreElt = querySelector('#score');
  Element _clockElt = querySelector('#clock');
  Element _buttonElt = querySelector('button');
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
    _buttonElt.onClick.listen(onStart);
    window.onKeyUp.listen(onKey);
    _clockElt.on['webkitAnimationEnd'].listen((event) =>
      _clockElt.classes.remove('pulsar')
      );
    
    HttpRequest.getString("onewords.json").then(getWords);
    onFrame(0.0);
  }
  
  void getWords(String jsonString) {
    words = JSON.decode(jsonString);
    _bodyElt.classes.add('ready');
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
    _bodyElt.classes
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
    _wordElt.classes.clear();
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
    _clockElt.text = ((msGameOver - msNow) / 1000).floor().toString();
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
        if (msWordTimeout - msNow >= 1.0) {
          _clockElt.classes.add('pulsar');
        }
        msGameOver += max(0.0, msWordTimeout - msNow);
        msWordTimeout = min(msWordTimeout, msNow + msFlashTime);
      }
      return;
    }
    
    _wordElt.classes.add('error');
    letterError = true;
  }
  
  void updateScore(int delta) {
    score += delta;
    // Should this be done in the animation frame instead of async?
    _scoreElt.text = "$score / $currentWord";
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
    _wordElt.children
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