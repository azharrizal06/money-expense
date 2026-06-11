import 'dart:io';

int fibonacci(int n) {
  if (n <= 1) return n;

  int a = 0;
  int b = 1;

  for (int i = 2; i <= n; i++) {
    int next = a + b;
    a = b;
    b = next;
  }

  return b;
}

void main() {
  stdout.write("Masukkan n: ");
  int n = int.parse(stdin.readLineSync()!);

  print("Bilangan Fibonacci ke-$n adalah ${fibonacci(n)}");
}
