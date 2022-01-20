import 'package:flutter/material.dart';
import 'package:my_shop/http_exception.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  static const routeName = '/Auth-screen';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                      Color.fromRGBO(255, 188, 117, 1).withOpacity(0.5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, 1])),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 90),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.deepOrange.shade800,

                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26, offset: Offset(0, 2))
                          ]),
                      child: Text(
                        "My Shop",
                        style: TextStyle(
                            color: Theme.of(context).accentTextTheme.headline6!.color,
                            fontSize: 50,
                            fontFamily: 'Anton'),
                      ),
                    ),
                  ),
                  Flexible(child: AuthCard())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

enum AuthMode { Login, SignUp }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {'email': '', 'password': ''};

  bool isLoading = false;
  final _passwordController = TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 300));

    _slideAnimation = Tween<Offset>(begin: Offset(0, -0.15), end: Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future _submit() async{
    if(!_formKey.currentState!.validate()){
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try{
      if(_authMode == AuthMode.Login){
       await Provider.of<Auth>(context, listen: false).logIn(_authData['email']!, _authData['password']!);
      }else{
        await Provider.of<Auth>(context, listen: false).signUp(_authData['email']!, _authData['password']!);
      }
    }on HttpException catch(error){
      var errMessage = 'Authentication failed';
      if(error.toString().contains("EMAIL_EXISTS")){
        errMessage = 'This email address is already in use';
      }else if(error.toString().contains("INVALID_EMAIL") || error.toString().contains("INVALID_PASSWORD")){
        errMessage = 'Invalid email or password';
      }else if(error.toString().contains("WEAK_PASSWORD")){
        errMessage = 'Password is too weak';
        }else if(error.toString().contains("EMAIL_NOT_FOUND")){
        errMessage = 'Could not find user with this email';
      }
        _showErrorDialog(errMessage);
    }
    catch(err){
      var errMessage = 'Could not authenticate you. please try again later';
      _showErrorDialog(err.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  void _showErrorDialog(String message){
    showDialog(context: context, builder: (ctx)=> AlertDialog(
      title: Text('An error Occurred'),
      content: Text(message),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: (){
            Navigator.of(context).pop();
          },
        )
      ],
    ));
  }

  void _switchAuthMode(){
    if(_authMode == AuthMode.Login){
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller.forward();
    }else{
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        constraints: BoxConstraints(minHeight: _authMode == AuthMode.SignUp ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val){
                    if(val!.isEmpty || !val.contains('@')){
                      return 'Inavalid email';
                    }
                  },
                  onSaved: (val){
                    _authData['email'] = val!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (val){
                    if(val!.isEmpty || val.length < 5 ){
                      return 'Password is too short';
                    }
                  },
                  onSaved: (val){
                    _authData['password'] = val!;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.SignUp ? 60 : 0,
                    maxHeight: _authMode == AuthMode.SignUp ? 70 : 0
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        enabled: _authMode == AuthMode.SignUp,
                        decoration: InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        // validator: (val){
                        //   if(val != _passwordController){
                        //     return "Password don't match";
                        //   }
                        // },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                if(isLoading)CircularProgressIndicator()
                else ElevatedButton(
                  child: Text(_authMode == AuthMode.Login ? 'Login' : 'Sign up'),
                  onPressed: _submit,
                ),
                TextButton(
                  onPressed: ()=> _switchAuthMode(),
                  child: Text('${_authMode == AuthMode.Login ? 'Sign up' : 'Login'} INSTEAD'),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
