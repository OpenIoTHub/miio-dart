import 'package:miio/miio.dart';

void main(List<String> args) {
  // Discover MIIO devices and print.
  Miio.discover('192.168.1.255', print);
}
