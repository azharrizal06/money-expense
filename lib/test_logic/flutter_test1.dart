import 'dart:io';

void main() {
  stdout.write("Masukkan angka: ");
  int angka = int.parse(stdin.readLineSync()!);

  if (angka % 2 == 0) {
    print("$angka adalah bilangan Genap");
  } else {
    print("$angka adalah bilangan Ganjil");
  }
}
