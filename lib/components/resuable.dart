import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

Image logoWidget(String imageName){
  return Image.asset(
    imageName,
    fit: BoxFit.fitWidth,
    width: 240,
    height: 240,
    color: Colors.white,
  );
}

TextField reusableTextField(String text,IconData icon,bool isPasswordType, TextEditingController controller){
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.white,
    style: TextStyle( color: Colors.white.withOpacity(0.9)),
    decoration: InputDecoration(prefixIcon: Icon(icon,color: Colors.white70,),
      labelText: text,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white.withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),borderSide: const BorderSide(width: 0,style: BorderStyle.none)),
    ),
    keyboardType: isPasswordType ? TextInputType.visiblePassword : TextInputType.emailAddress,
  );
}

TextField DataTextField(String text,IconData icon,bool isPasswordType, TextEditingController controller){
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    enableSuggestions: !isPasswordType,
    autocorrect: !isPasswordType,
    cursorColor: Colors.blueGrey,
    style: TextStyle( color: Colors.blueGrey.withOpacity(0.9)),
    decoration: InputDecoration(prefixIcon: Icon(icon,color: Colors.blueGrey,),
      labelText: text,
      labelStyle: TextStyle(color: Colors.blueGrey),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Colors.white10.withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0),borderSide: const BorderSide(width: 0,style: BorderStyle.solid,color: Colors.white10)),
    ),
    keyboardType: isPasswordType ? TextInputType.visiblePassword : TextInputType.emailAddress,
  );
}


Container cardsAdmin(BuildContext context, String title, IconData icon_name,Function onTap){
    return Container(
      width: MediaQuery.of(context).size.width/2.3,
      height: 200,
      margin: const EdgeInsets.fromLTRB(0, 15, 0, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10)
      ),
      child: ElevatedButton(
        onPressed: () {
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              SizedBox(height: 10,),
              Center(child: Icon(icon_name,size: 100,color: Color(0xffE75480),)),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.black26;
              }
              return Colors.white;
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
      ),
    );
}

Container buttonPG(BuildContext context, String title, IconData icon_name,Function onTap){
  return Container(
    width: MediaQuery.of(context).size.width/2.3,
    height: 56,
    margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
    ),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 15),
        child: Column(
          children: [
            // SizedBox(height: 10,),
            // Center(child: Icon(icon_name,size: 100,color: Color(0xffE75480),)),
            Center(
              child: Text(
                title,
                style: const TextStyle(
                     fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.white;
            }
            return Color(0xff0094FF);
          }),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Color(0xff0094FF);
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),side:  BorderSide(color: Color(0xff0094FF)),))),
    ),
  );
}


Container Uploadimage(BuildContext context, String title, Function onTap) {
    return Container(
      child: Column(
        children: [
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            dashPattern: const [10, 4],
            strokeCap: StrokeCap.round,
            color: Colors.grey, // Change color as needed
            child: Container(
              width: MediaQuery.of(context).size.width/1.5,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    color: Colors.grey,
                    size: 40,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Click to upload the file',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade400),
                  ),
                  SizedBox(height: 5,),
                  ElevatedButton(onPressed: () {
                    onTap();
                  },
                    child: Text(
                      title,
                      style: const TextStyle(
                           fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.white;
                          }
                          return Color(0xff0094FF);
                        }),
                        backgroundColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Color(0xff0094FF);
                          }
                          return Colors.white;
                        }),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),side: BorderSide(color: Color(0xff0094FF)),))),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
}

Container firebaseUIButton(BuildContext context, String title, Function onTap) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 50,
    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90)),
    child: ElevatedButton(
      onPressed: () {
        onTap();
      },
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return Colors.black26;
            }
            return Colors.white;
          }),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))),
    ),
  );
}