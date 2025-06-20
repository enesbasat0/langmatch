import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Friends extends StatefulWidget {
  @override
  _FriendsState createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  int _selectedIndex = 0; // Ana sayfa sekmesi seçili olacak

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        context.go('/friends'); // Ana sayfa
        break;
      case 1:
        context.go('/camera'); // Kamera sayfası
        break;
      case 2:
        context.go('/messages');
        break;
      case 3:
        context.go('/profile'); // Profil sayfası
        break;
    }
  }

  Widget buildUserContainer(String userName, String description, String url) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(url), // Replace with actual user image
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange[500],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(width: 10),
            Text(
              'Lang Match',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.orange[300],
        child: ListView(
          children: [
            buildUserContainer("Keyvan Arasteh", "Yazılım Uzmanı", "https://avatars.githubusercontent.com/u/16303698?v=4"),
            buildUserContainer("Cenk Aydın", "Profesyonel Voleybol Oyuncusu", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTEa8HrYurtIa9uEgcSLNJsA6BiCF0h7WwFrA&s"),
            buildUserContainer("Enes Başat", "E Ticaret Uzmanı", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmjWgOVc0jDICcE6xG1kU5tK8eri0K3y9Fkw&s"),
            buildUserContainer("Oğuz Çavuş", "Toner Satış Uzmanı", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqITnd_uqqay5MSy_7vsMYG5MqtzhHp6Mgbw&s"),
            buildUserContainer("Ayça 22", "Tanınmış Kişi", "https://icdn.ensonhaber.com/crop/1200x0/resimler/diger/kok/2023/03/17/ayca-22-kamera-acti-ile-tanindi-internetin-gizemli-aycasi-sonun_44bc5421.jpg"),
            buildUserContainer("Efe Çakmakcı","Secret Service","https://st5.depositphotos.com/16122460/66903/i/450/depositphotos_669035314-stock-photo-anonymous-man-hood-using-laptop.jpg"),
            buildUserContainer("Hüseyin Arda Akşit","Üfürükçü Hoca","https://st.depositphotos.com/3332767/4585/i/450/depositphotos_45859937-stock-photo-mature-priest-holding-bible.jpg"),
            buildUserContainer("Yasin Karagöz", "Full-Stack Developer","https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/2dd5e5125369651.6117b731d0915.jpg"),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/about');
              },
              child: Text('Proje Hakkında'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/contact');
              },
              child: Text('İletişim'),
            ),
          ],
        ),
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
