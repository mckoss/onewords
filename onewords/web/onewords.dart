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
  bool letterError;
  
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
    wordElt.classes.clear();
    letterError = false;
    setWord(words[currentWord], missingLetters);
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
    int index = missingLetters.indexOf(ch);
    if (index == -1) {
      return;
    }
    print("Pressed key '${ch}'");
    
    missingLetters = missingLetters.replaceFirst(ch, '');
    setWord(words[currentWord], missingLetters);
    if (letterError) {
      return;
    }
    
    if (index == 0) {
      if (missingLetters.length == 0) {
        updateScore(1);
      }
      return;
    }
    wordElt.classes.add('error');
  }
  
  void updateScore(int delta) {
    score += delta;
    // Should this be done in the animation frame instead of async?
    scoreElt.text = "$score";
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