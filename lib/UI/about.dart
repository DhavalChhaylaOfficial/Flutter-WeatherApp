import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AboutPage extends StatelessWidget {
  final Color primaryColor = const Color(0xff38BDF8);

  @override
  final String contactNum = '+91 90545 23197';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'About Us',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor, // Change app bar color to green
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Card(
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Devloper Info',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(4), // Adjust padding as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryColor, // Set the border color to blue
                        width: 4, // Set the border width
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: AssetImage('assets/aboutimg.jpg'),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Dhaval Chhayla',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    textAlign: TextAlign.center,
                    'IT Enthusiast & Tech Visionary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // SizedBox(height: 10),
                  // Text(
                  //   textAlign: TextAlign.center,
                  //   'Transforming Ideas into Reality with my technical abilities and solid expertise in designing and implementing complex systems, developing innovative solutions and managing projects from start to finish. Aside from the coding, I am a good communicator that combines analytical talents with creativity.',
                  //   style: TextStyle(
                  //     fontSize: 12.5,
                  //   ),
                  // ),
                  //SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     FlutterSocialButton(
                  //       onTap: () async {
                  //         Uri uri = Uri.parse(
                  //           'mailto:dhavalhchhayla@gmail.com?subject=Weather App&body=Hi, Dhaval Chhayla,\n',
                  //         );
                  //         if (!await launcher.launchUrl(uri)) {
                  //           debugPrint(
                  //               "Could not launch the uri"); // because the simulator doesn't has the email app
                  //         }
                  //       },
                  //       buttonType: ButtonType.email,
                  //       mini: true,
                  //       iconColor: Colors.white,
                  //     ),
                  //     SizedBox(width: 16),
                  //     FlutterSocialButton(
                  //       onTap: () async {
                  //         launcher.launchUrl(
                  //           Uri.parse('https://www.linkedin.com/in/dhaval-chhayla'),
                  //           mode: launcher.LaunchMode.externalApplication,
                  //         );
                  //       },
                  //       buttonType: ButtonType.linkedin,
                  //       mini: true,
                  //       iconColor: Colors.white,
                  //     ),
                  //     SizedBox(width: 16),
                  //     FlutterSocialButton(
                  //       onTap: () async {
                  //
                  //       },
                  //       buttonType: ButtonType.github,
                  //       mini: true,
                  //       iconColor: Colors.white,
                  //     ),
                  //   ],
                  // ),

                  SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            Uri uri = Uri.parse(
                              'mailto:dhavalhchhayla@gmail.com?subject=Weather App&body=Hi, Dhaval Chhayla,\n',
                            );
                            if (!await launcher.launchUrl(uri)) {
                            debugPrint(
                            "Could not launch the uri"); // because the simulator doesn't has the email app
                            }
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: primaryColor,
                            // Customize the color of the circle
                            child: Icon(
                              Icons.email,
                              size: 27,
                              color: Colors.white, // Customize the color of the icon
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16,),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            launcher.launchUrl(
                              Uri.parse('https://www.linkedin.com/in/dhaval-chhayla'),
                              mode: launcher.LaunchMode.externalApplication,
                            );
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: primaryColor, // Customize the color of the circle
                            child: Image.asset(
                              'assets/linkedin.png', // Provide the path to your image asset
                              width: 32, // Adjust the width of the image
                              height: 32, // Adjust the height of the image
                              fit: BoxFit.cover, // Adjust how the image is fitted inside the CircleAvatar
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16,),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            launcher.launchUrl(
                              Uri.parse('https://github.com/DhavalChhaylaOfficial'),
                              mode: launcher.LaunchMode.externalApplication,
                            );
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: primaryColor, // Customize the color of the circle
                            child: Image.asset(
                              'assets/github.png', // Provide the path to your image asset
                              width: 32, // Adjust the width of the image
                              height: 32, // Adjust the height of the image
                              fit: BoxFit.cover, // Adjust how the image is fitted inside the CircleAvatar
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Text(
                    textAlign: TextAlign.center,
                    'Copyright (c) 2024 Dhaval Chhayla \nAll rights reserved.',
                    // Added "Developed by TechPrenuer" in the footer
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AboutPage(),
  ));
}
