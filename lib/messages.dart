import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Messages extends StatefulWidget {
  @override
  _MessagesState createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  int _selectedIndex = 2; // Mesajlar sekmesi seçili

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/friends');
        break;
      case 1:
        context.go('/camera');
        break;
      case 2:
        // Zaten mesajlar sayfasındayız
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  // Örnek mesaj listesi
  final List<Map<String, dynamic>> chats = [
    {
      'name': 'Keyvan Arasteh',
      'lastMessage': 'Merhaba, nasılsın?',
      'time': '12:30',
      'unread': 2,
      'avatar': 'https://avatars.githubusercontent.com/u/16303698?v=4',
      'isOnline': true,
    },
    {
      'name': 'Cenk Aydın',
      'lastMessage': 'kanka gs-fb voleybol maçına gelecek misin?',
      'time': '11:45',
      'unread': 0,
      'avatar': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEa8HrYurtIa9uEgcSLNJsA6BiCF0h7WwFrA&s',
      'isOnline': true,
    },
    {
      'name': 'Enes Başat',
      'lastMessage': 'Yarın görüşelim mi?',
      'time': '10:15',
      'unread': 1,
      'avatar': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmjWgOVc0jDICcE6xG1kU5tK8eri0K3y9Fkw&s',
      'isOnline': true,
    },
    {
      'name': 'Oğuz Çavuş',
      'lastMessage': 'Okula Geliyor musun?',
      'time': '10:15',
      'unread': 3,
      'avatar': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqITnd_uqqay5MSy_7vsMYG5MqtzhHp6Mgbw&s',
      'isOnline': false,
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[300],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          'Mesajlar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Arama fonksiyonu
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Yeni mesaj oluşturma
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[300]!, Colors.deepOrange[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(chat['avatar']),
                    ),
                    if (chat['isOnline'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  chat['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  chat['lastMessage'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                trailing: SizedBox(
                  width: 45,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        chat['time'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      if (chat['unread'] > 0)
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          padding: EdgeInsets.zero,
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              chat['unread'].toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                onTap: () {
                  // Mesaj detayına git
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni mesaj oluştur
        },
        backgroundColor: Colors.deepOrange,
        child: Icon(Icons.message),
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