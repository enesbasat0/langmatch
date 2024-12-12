import 'package:flutter/material.dart';

class Friends extends StatelessWidget {
  const Friends({super.key});

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
            buildUserContainer("Oğuz Çavuş", "Toner Satış Uzmanı", "https://media-ams2-1.cdn.whatsapp.net/v/t61.24694-24/454053502_877112450991019_5922453246373383210_n.jpg?stp=dst-jpg_tt6&ccb=11-4&oh=01_Q5AaIC54XIpnI0O5_W11EMkiLEo__3k-UPiOoYaxUtbfThaK&oe=676873F9&_nc_sid=5e03e0&_nc_cat=108"),
            buildUserContainer("Ayça 22", "Tanınmış Kişi", "https://icdn.ensonhaber.com/crop/1200x0/resimler/diger/kok/2023/03/17/ayca-22-kamera-acti-ile-tanindi-internetin-gizemli-aycasi-sonun_44bc5421.jpg"),

          ],
        ),
      ),
    );
  }
}
