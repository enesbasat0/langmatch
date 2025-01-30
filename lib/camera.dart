import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:langmatch/services/webrtc_service.dart';
import 'dart:async';

class Camera extends StatefulWidget {
  const Camera({Key? key}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  int _selectedIndex = 1;
  bool _isSearching = false;
  bool _isConnected = false;
  bool _isCameraOn = false;
  
  WebRTCService? _webRTCService;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  Timer? _acceptTimer;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _initializeWebRTC();
  }

  void _initializeWebRTC() {
    _webRTCService = WebRTCService(DateTime.now().millisecondsSinceEpoch.toString());
    _webRTCService!.onMatchFound = () {
      if (mounted) {
        setState(() {
          _isConnected = true;
          _remainingSeconds = 30;
        });
        _startAcceptTimer();
      }
    };
  }

  void _startAcceptTimer() {
    _acceptTimer?.cancel();
    _acceptTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _handleReject();
      }
    });
  }

  void _handleAccept() async {
    _acceptTimer?.cancel();
    setState(() {
      _isConnected = true;
    });
    await _webRTCService!.acceptMatch();
    await _webRTCService!.initialize();
    
    if (_webRTCService!.localStream != null) {
      setState(() {
        _localRenderer.srcObject = _webRTCService!.localStream;
        _isCameraOn = true;
      });
    }

    setState(() {
      _isSearching = false;
    });

    _webRTCService!.peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };
  }

  void _handleReject() {
    _acceptTimer?.cancel();
    setState(() {
      _isConnected = false;
      _isCameraOn = false;
    });
    
    _webRTCService?.dispose();
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
  }

  void _handleFindMatch() async {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
    });

    try {
      await _webRTCService!.findMatch();
    } catch (e) {
      print('Eşleşme hatası: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: $e')),
      );
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _acceptTimer?.cancel();
    _webRTCService?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/friends');
        break;
      case 1:
        // Zaten kamera sayfasındayız
        break;
      case 2:
        context.go('/messages');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  Widget _buildVideoContainer({bool isLocal = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isLocal
            ? (_isCameraOn && _localRenderer.srcObject != null
                ? RTCVideoView(
                    _localRenderer,
                    mirror: true,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : _buildPlaceholder(isLocal: true))
            : (_isConnected && _remoteRenderer.srcObject != null
                ? RTCVideoView(
                    _remoteRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : _buildPlaceholder(isLocal: false)),
      ),
    );
  }

  Widget _buildPlaceholder({required bool isLocal}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLocal ? (_isCameraOn ? Icons.videocam : Icons.videocam_off) : Icons.person,
            size: 50,
            color: Colors.white54,
          ),
          SizedBox(height: 8),
          Text(
            isLocal ? (_isCameraOn ? 'Kameranız Açık' : 'Kameranız Kapalı') : 'Diğer Kullanıcı',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[300],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          'Dil Arkadaşı Bul',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[300]!, Colors.deepOrange[400]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                if (_isConnected)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildVideoContainer(isLocal: true),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildVideoContainer(isLocal: false),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.videocam_off,
                              size: 100,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 16),
                            if (_isSearching)
                              Column(
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.orange,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Dil arkadaşı aranıyor...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          if (_isConnected)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(16),
                color: Colors.black54,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Eşleşme Bulundu!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '$_remainingSeconds saniye içinde kabul etmelisiniz',
                      style: TextStyle(color: Colors.orange),
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _remainingSeconds / 30,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _remainingSeconds > 10 ? Colors.green : Colors.orange,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: _handleReject,
                          child: Text('Reddet'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                        ElevatedButton(
                          onPressed: _handleAccept,
                          child: Text('Kabul Et'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          if (!_isConnected)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _isSearching ? null : _handleFindMatch,
                  child: Text(_isSearching ? 'Eşleşme Aranıyor...' : 'Eşleşme Bul'),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Kamera',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mesajlar',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profilim',
            backgroundColor: Colors.orange,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.orange[300],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
} 