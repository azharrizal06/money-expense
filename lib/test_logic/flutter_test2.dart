void main() {
  for (int i = 1; i <= 100; i++) {
    if (i % 3 == 0 && i % 5 == 0) {
      print("Developer Indonesia");
    } else if (i % 3 == 0) {
      print("Developer");
    } else if (i % 5 == 0) {
      print("Indonesia");
    } else {
      print(i);
    }
  }
}
