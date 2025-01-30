import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:langmatch/friends.dart';
import 'package:langmatch/main.dart';
import 'package:langmatch/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langmatch/config/firebase_config.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    final firebaseOptions = await FirebaseConfig.platformOptions;
    await Firebase.initializeApp(options: firebaseOptions);
    runApp(MyApp());
  } catch (e) {
    print('Uygulama başlatma hatası: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Uygulama başlatılırken bir hata oluştu.\nHata: $e',
              textAlign: TextAlign.center),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/friends',
      builder: (context, state) => Friends(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => Profile(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => Register(),
    ),
  ],
);

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        print('Kayıt işlemi başlatılıyor...');
        print('Email: ${_emailController.text.trim()}');
        
        // Firebase ile kullanıcı oluşturma
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        print('Kullanıcı oluşturuldu, yönlendirme yapılıyor...');

        // Başarılı kayıt sonrası friends sayfasına yönlendirme
        if (!mounted) return;
        context.go('/friends');
      } on FirebaseAuthException catch (e) {
        print('Firebase Auth Hatası: ${e.code} - ${e.message}');
        String errorMessage = '';
        
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'Şifre çok zayıf.';
            break;
          case 'email-already-in-use':
            errorMessage = 'Bu email adresi zaten kullanımda.';
            break;
          case 'invalid-email':
            errorMessage = 'Geçersiz email adresi.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/şifre girişi devre dışı bırakılmış.';
            break;
          case 'network-request-failed':
            errorMessage = 'İnternet bağlantısı hatası.';
            break;
          default:
            errorMessage = 'Bir hata oluştu: ${e.message}';
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        print('Genel Hata: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beklenmeyen bir hata oluştu: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[300]!, Colors.deepOrange[400]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 50,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Lang Match',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen email adresinizi girin';
                        }
                        if (!value.contains('@')) {
                          return 'Geçerli bir email adresi girin';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Şifre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen şifrenizi girin';
                        }
                        if (value.length < 6) {
                          return 'Şifre en az 6 karakter olmalıdır';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/'),
                      child: Text(
                        'Zaten hesabın var mı? Giriş Yap',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
