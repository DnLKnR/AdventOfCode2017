import 'dart:io';

main() {
  var file = new File("input.txt");
  var input = file.readAsStringSync();
  var moveStrings = input.replaceAll("\n", "").split(",");

  var moves = moveStrings.map(getOperation);

  String starting = "abcdefghijklmnop";

  //Part 1: Perform the dance once
  String ending = starting;
  Map<String, String> map = new Map<String, String>();
  map[starting] = ending;
  moves.forEach((move) => map[starting] = move.Perform(map[starting]));
  print(map[starting]);

  //Part 2: Perform the dance a billion times (use a map to make it faster)
  var i = 1000000000;
  while (i-- > 0) {
    if (!map.containsKey(ending)) {
      map[ending] = ending;
      for (var move in moves) {
        map[ending] = move.Perform(map[ending]);
      }
    }
    ending = map[ending];
  }
  print(ending);
}

Move getOperation(String operationString) {
  String moveType = operationString.substring(0, 1);
  String description = operationString.substring(1);
  switch(moveType) {
    case "s":
      return new Spin(description);
    case "x":
      return new Exchange(description);
    case "p":
      return new Partner(description);
  }
  throw new Exception("Invalid Dance Move: " + moveType);
}

abstract class Move {
  String Perform(String text);
}

class Spin implements Move {
  var Index;

  Spin(String input) {
    this.Index = int.parse(input);
  }

  String Perform(String text) {
    var index = text.length - this.Index;
    var last = text.substring(0, index);
    var first = text.substring(index);
    return first + last;
  }
}

class Exchange implements Move {
  int First;
  int Second;

  Exchange(String input) {
    var exchangers = input.split("/");
    this.First = int.parse(exchangers[0]);
    this.Second = int.parse(exchangers[1]);
  }

  String Perform(String text) {
    var firstDancer = text[this.First];
    var secondDancer = text[this.Second];
    return text.replaceRange(this.First, this.First + 1, secondDancer)
        .replaceRange(this.Second, this.Second + 1, firstDancer);
  }
}

class Partner implements Move {
  String First;
  String Second;

  Partner(String input) {
    var partners = input.split("/");
    this.First = partners[0];
    this.Second = partners[1];
  }

  String Perform(String text) {
    var firstIndex = text.lastIndexOf(this.First);
    var secondIndex = text.lastIndexOf(this.Second);
    return text.replaceRange(firstIndex, firstIndex + 1, this.Second)
        .replaceRange(secondIndex, secondIndex + 1, this.First);
  }
}