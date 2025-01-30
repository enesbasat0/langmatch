import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class WebRTCService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  final String roomId;
  late final DatabaseReference _roomsRef;
  DatabaseReference? roomRef;
  bool isInitiator = false;
  static final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Eşleşme bulunduğunda çağrılacak callback
  Function? onMatchFound;

  WebRTCService(this.roomId) {
    // Firebase veritabanı referansını oluştur
    _roomsRef = _database.ref('rooms').child(roomId.replaceAll(RegExp(r'[.#$\[\]/]'), '_'));
  }

  Future<bool> _checkConnection() async {
    try {
      // Test için rooms koleksiyonuna erişmeyi dene
      await _roomsRef.get();
      return true;
    } catch (e) {
      print('Bağlantı kontrolü hatası: $e');
      return false;
    }
  }

  Future<bool> findMatch() async {
    try {
      print('Eşleşme aranıyor...');
      final connected = await _checkConnection();
      if (!connected) {
        print('Firebase bağlantısı yok!');
        return false;
      }

      final snapshot = await _roomsRef
          .orderByChild('status')
          .equalTo('waiting')
          .get();

      print('Mevcut odalar kontrol edildi: ${snapshot.value}');
      
      if (snapshot.exists && snapshot.value != null) {
        print('Boş oda bulundu');
        final rooms = Map<String, dynamic>.from(snapshot.value as Map);
        final availableRoom = rooms.entries.first;
        
        if (availableRoom.value['peer1'] == FirebaseAuth.instance.currentUser?.uid) {
          print('Kendi odamız, yeni oda oluşturuluyor...');
          return await createNewRoom();
        }

        String sanitizedRoomKey = availableRoom.key.replaceAll(RegExp(r'[.#$\[\]/]'), '_');
        roomRef = _roomsRef.child(sanitizedRoomKey);
        print('Odaya katılınıyor: $sanitizedRoomKey');
        
        try {
          await roomRef!.update({
            'status': 'pending',
            'peer2': FirebaseAuth.instance.currentUser?.uid,
            'peer2_accepted': false,
            'updated': ServerValue.timestamp,
          });
          
          isInitiator = false;
          onMatchFound?.call(); // Eşleşme callback'ini çağır
          bool accepted = await waitForAcceptance();
          if (!accepted) {
            print('Eşleşme kabul edilmedi veya zaman aşımına uğradı');
            await roomRef?.remove();
            return false;
          }
          return true;
        } catch (e) {
          print('Oda güncelleme hatası: $e');
          return false;
        }
      } else {
        print('Boş oda bulunamadı, yeni oda oluşturuluyor...');
        return await createNewRoom();
      }
    } catch (e) {
      print('Eşleşme hatası: $e');
      return false;
    }
  }

  Future<bool> createNewRoom() async {
    try {
      String sanitizedRoomId = roomId.replaceAll(RegExp(r'[.#$\[\]/]'), '_');
      roomRef = _roomsRef.child(sanitizedRoomId);
      await roomRef!.set({
        'status': 'waiting',
        'peer1': FirebaseAuth.instance.currentUser?.uid,
        'peer1_accepted': false,
        'created': ServerValue.timestamp,
      });
      
      isInitiator = true;
      print('Yeni oda oluşturuldu: $sanitizedRoomId');
      
      bool matched = await waitForMatch();
      if (!matched) {
        print('Eşleşme zaman aşımına uğradı');
        await roomRef?.remove();
      }
      return matched;
    } catch (e) {
      print('Oda oluşturma hatası: $e');
      return false;
    }
  }

  Future<bool> waitForMatch() async {
    try {
      print('Eşleşme bekleniyor...');
      final completer = Completer<bool>();
      Timer? timer;
      late StreamSubscription<DatabaseEvent> subscription;

      timer = Timer(Duration(seconds: 30), () {
        print('Eşleşme zaman aşımı');
        subscription.cancel();
        completer.complete(false);
        roomRef?.remove();
      });

      subscription = roomRef!.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          print('Oda durumu değişti: ${data['status']}');
          if (data['status'] == 'pending' && data['peer2'] != null) {
            print('Eşleşme bulundu! Kabul bekleniyor...');
            timer?.cancel();
            subscription.cancel();
            onMatchFound?.call(); // Eşleşme callback'ini çağır
            completer.complete(true);
          }
        }
      });

      bool matched = await completer.future;
      if (matched) {
        return await waitForAcceptance();
      }
      return false;
    } catch (e) {
      print('Eşleşme bekleme hatası: $e');
      return false;
    }
  }

  Future<bool> waitForAcceptance() async {
    try {
      print('Eşleşme kabulü bekleniyor...');
      final completer = Completer<bool>();
      Timer? timer;
      late StreamSubscription<DatabaseEvent> subscription;

      timer = Timer(Duration(seconds: 30), () {
        print('Kabul zaman aşımı');
        subscription.cancel();
        completer.complete(false);
      });

      subscription = roomRef!.onValue.listen((event) {
        if (event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          bool peer1Accepted = data['peer1_accepted'] == true;
          bool peer2Accepted = data['peer2_accepted'] == true;
          
          if (peer1Accepted && peer2Accepted) {
            print('Her iki taraf da kabul etti!');
            timer?.cancel();
            subscription.cancel();
            roomRef?.update({'status': 'connected'});
            completer.complete(true);
          }
        }
      });

      return await completer.future;
    } catch (e) {
      print('Kabul bekleme hatası: $e');
      return false;
    }
  }

  Future<void> acceptMatch() async {
    try {
      if (isInitiator) {
        await roomRef?.update({'peer1_accepted': true});
      } else {
        await roomRef?.update({'peer2_accepted': true});
      }
      print('Eşleşme kabul edildi');
    } catch (e) {
      print('Eşleşme kabul hatası: $e');
    }
  }

  Future<void> rejectMatch() async {
    try {
      await roomRef?.remove();
      print('Eşleşme reddedildi');
    } catch (e) {
      print('Eşleşme red hatası: $e');
    }
  }

  Future<void> initialize() async {
    print('WebRTC başlatılıyor...');
    final configuration = {
      'iceServers': [
        {
          'urls': [
            'stun:stun1.l.google.com:19302',
            'stun:stun2.l.google.com:19302'
          ]
        }
      ]
    };

    peerConnection = await createPeerConnection(configuration);
    print('Peer bağlantısı oluşturuldu');

    // Yerel medya akışını al
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    });
    print('Kamera ve mikrofon erişimi alındı');

    // Yerel akışı peer connection'a ekle
    localStream!.getTracks().forEach((track) {
      peerConnection!.addTrack(track, localStream!);
    });

    // ICE adaylarını dinle ve gönder
    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      print('ICE adayı bulundu');
      roomRef?.child('candidates').push().set(candidate.toMap());
    };

    // Uzak akışı dinle
    peerConnection!.onTrack = (RTCTrackEvent event) {
      print('Uzak video akışı alındı');
      remoteStream = event.streams[0];
    };

    // Sinyal verilerini dinle
    roomRef?.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        print('Sinyal verisi alındı: ${data.keys}');
        
        if (!isInitiator && data['offer'] != null && data['answer'] == null) {
          print('Teklif alındı, yanıt gönderiliyor...');
          handleOffer(data['offer']);
        }
        
        if (isInitiator && data['answer'] != null) {
          print('Yanıt alındı');
          handleAnswer(data['answer']);
        }
      }
    });

    // ICE adaylarını dinle
    roomRef?.child('candidates').onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        print('Yeni ICE adayı alındı');
        final candidate = Map<String, dynamic>.from(event.snapshot.value as Map);
        peerConnection!.addCandidate(
          RTCIceCandidate(
            candidate['candidate'],
            candidate['sdpMid'],
            candidate['sdpMLineIndex'],
          ),
        );
      }
    });

    if (isInitiator) {
      print('Teklif oluşturuluyor...');
      await createOffer();
    }
  }

  Future<void> createOffer() async {
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    
    await roomRef?.update({
      'offer': offer.toMap(),
    });
  }

  Future<void> handleOffer(Map<String, dynamic> offer) async {
    await peerConnection!.setRemoteDescription(
      RTCSessionDescription(offer['sdp'], offer['type']),
    );

    RTCSessionDescription answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);

    await roomRef?.update({
      'answer': answer.toMap(),
    });
  }

  Future<void> handleAnswer(Map<String, dynamic> answer) async {
    await peerConnection!.setRemoteDescription(
      RTCSessionDescription(answer['sdp'], answer['type']),
    );
  }

  void dispose() {
    localStream?.dispose();
    remoteStream?.dispose();
    peerConnection?.dispose();
    roomRef?.remove();
  }
} 