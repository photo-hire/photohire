import 'package:flutter/material.dart';

class PhotographerManageProfileScreen extends StatefulWidget {
  const PhotographerManageProfileScreen({super.key});

  @override
  State<PhotographerManageProfileScreen> createState() => _PhotographerManageProfileScreenState();
}

class _PhotographerManageProfileScreenState extends State<PhotographerManageProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Container(
       decoration:  BoxDecoration(
          gradient:  LinearGradient(
            transform: GradientRotation(11),
            
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 200, 148, 249), // Purple (Top-left)
              Color.fromARGB(255, 162, 213, 255), // Blue (Top-right)
              Colors.white,      // White (Bottom)
            ],
          ),
      
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 30, 15,0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text('Manage Your Profile',style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold
              ),),
              SizedBox(height: 30,),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[900],
                  borderRadius: BorderRadius.circular(10)
                ),
                 child: Row(
                  children: [
                    IconButton(onPressed: (){}, icon: Icon(Icons.add,size: 60,color: Colors.white,)),
                    Text('Add a new post',style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                    ),)
                  ],
                 ), 
              ),
              SizedBox(height: 20,),
              Text('Your Profile',style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold
              ),),
              SizedBox(height: 20,),
              Expanded(child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10
                    ),
                    itemCount: 10, 
                  itemBuilder: (context, index) {
                    return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'asset/image/weddingphoto.jpg',
              fit: BoxFit.cover,
              height: 150, 
              width: double.infinity, 
            ),
          );
                  },
                  
                  ),)
              

            ],
          ),
        ),
      ),
    ));
  }
}