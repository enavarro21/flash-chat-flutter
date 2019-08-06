import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome_screen';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  // In order to use animations
  AnimationController controller;
  // In order to use curves, use type Animation()
  // When using Curves, upperBound cannot be greater than 1
  Animation animation;


  @override
  void initState() {
    super.initState();

    // Create the a singleTicker based animation controller
    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      // Upper & Lower Bound properties can be changed here
      // upperBound: 1,
    );

    // Initialize animation to new curvedAnimation
    // Parent is what the curve is applied to, and type of curve
    // animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);

    // Use ColorTween to animate between two Colors to build a new animation
    animation = ColorTween(begin: Colors.grey, end: Colors.white).animate(controller);

    // Get the animation and get it to start
    //Proceed the animation forward
    controller.forward();

    // Get the animation to reverse, must provide a from: property
    // from: is the new starting point
    // controller.reverse(from: 1.0);

    // Get the animation to loop, we need to know when the animation is done
    // End of Reverse animation is AnimationStatus.dismissed
    // End of Forward animation is AnimationStatus.complete
    // controller.forward();
    // animation.addStatusListener((status) {
    //   // Can now use .dismissed and .complete to check if animation is done

    //   if (status == AnimationStatus.completed) {
    //     controller.reverse(from: 1.0);
    //   } else if (status == AnimationStatus.dismissed) {
    //     controller.forward();
    //   }
    // });

    // Always @override the dispose() method when the screen leaves so resources
    // are not taken up by the application
    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }


    // To see what the controller is doing, add a listener that takes a callback
    controller.addListener(() {
      // Must call setState so Flutter knows to update the screen
      setState(() {});
      // print(controller.value);
      print(animation.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // controller.value can be used, it is a a number between 0-1 in this case
      // to specify the opacity of the background
      // backgroundColor: Colors.red.withOpacity(controller.value),
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    // Can even use controller.value to animate the logo height
                    // height: animation.value * 100,
                    height: 60,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  // Animate the text with the controller.value 0-100
                  // Loading Indicator
                  // '${controller.value.toInt()}%',
                  text: ['Flash Chat'],
                  textStyle: TextStyle(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                elevation: 5.0,
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(30.0),
                child: MaterialButton(
                  onPressed: () {
                    //Go to login screen.
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Log In',
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(30.0),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () {
                    //Go to registration screen.
                    Navigator.pushNamed(context, RegistrationScreen.id);
                  },
                  minWidth: 200.0,
                  height: 42.0,
                  child: Text(
                    'Register',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
