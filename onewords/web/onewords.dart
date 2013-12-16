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
  Element nextWord;
  
  OneWordGame(this.nextWord) {
    HttpRequest.getString("onewords.json")
    .then(getWords);
  }
  
  void getWords(String jsonString) {
    words = JSON.decode(jsonString);
    print(words);
    start();
  }
  
  void start() {
    nextWord.text = words[0];
  }
}