/*
Copyright (C) 2020 Jason C.H

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

library miio;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:tuple/tuple.dart';

part 'utils.dart';
part 'packet.dart';

/// MIIO LAN protocol.
class Miio {
  /// Send discovery packet to [ip].
  /// [callback] will be invoked while receiving a response.
  static void discover(
    String ip,
    Function(Tuple2<InternetAddress, MiioPacket>) callback, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    var udpSocket =
        await RawDatagramSocket.bind(InternetAddress.anyIPv4, 54321);
    var broadcast = udpSocket.asBroadcastStream();

    var subscription = broadcast.listen((event) {
      if (event != RawSocketEvent.read) return;
      Datagram dg = udpSocket.receive();
      callback(Tuple2(dg.address, MiioPacket.parse(dg.data)));
    });
    Timer(timeout, () {
      subscription.cancel();
      udpSocket.close();
    });

    udpSocket.send(
        MiioPacket.hello().binary, InternetAddress.tryParse(ip), 54321);
  }
}
