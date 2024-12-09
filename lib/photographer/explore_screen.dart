import 'package:flutter/material.dart';
import 'package:photohire/customwidgets/explore_screen_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
          padding: const EdgeInsets.fromLTRB(15, 20, 15,0),
          child: Column(
            children: [
              Text('Explore',style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold
              ),),
              SizedBox(height: 10,),
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  hintText: 'search...',
                  hintStyle: TextStyle(
                    color: Colors.grey
                  ),
                  prefixIcon: Icon(Icons.search,color: Colors.grey,),
                  suffixIcon: Icon(Icons.tune,color: Colors.grey,)
                ),
              ),
              SizedBox(height: 20,),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10
                    ), 
                  itemBuilder: (context, index) {
                    return ExploreScreenWidget(image: 'asset/image/weddingphoto.jpg',
                    title: 'Studio one',
                    rating: 4.5,);
                  },
                  
                  ),
              )
            ],
          ),
        )
      ),
    ));
  }
}