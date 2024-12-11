import 'package:flutter/material.dart';

class PhotographerDetailsScreen extends StatefulWidget {
  Map<String,dynamic> studioDetails;

  PhotographerDetailsScreen({super.key,required this.studioDetails});

  @override
  State<PhotographerDetailsScreen> createState() => _PhotographerDetailsScreenState();
}

class _PhotographerDetailsScreenState extends State<PhotographerDetailsScreen> {
  List images = ['asset/image/weddingphoto.jpg','asset/image/weddingphoto.jpg','asset/image/weddingphoto.jpg'];

 late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Image Section
            Container(
              height: 1000, // Height for the stack
              child: Stack(
                children: [
                  // Background Image
                  PageView.builder(
                    controller: _pageController,
        itemCount: images.length, // Length of images array
         onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
        itemBuilder: (context, index) {
          // Displaying image from the list of images (if available)
          String imageUrl = images[index];
          
          return Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
              // Dots Indicator
        Positioned(
          top: 280,
          left: 160,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 12 : 8, // Larger dot for the current index
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Colors.white : Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),

                  // Back Button
                  Positioned(
                    top: 40,
                    left: 16,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: 300,
                    child: Container(
                      
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: widget.studioDetails['companyLogo']!=null?
                                NetworkImage(widget.studioDetails['companyLogo']):null,
                                child: widget.studioDetails['companyLogo'] == null?
                                Text('Logo here',style: TextStyle(
                                  fontSize: 8
                                ),):null,
                              ),
                              SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  
                                  Text(
                                    widget.studioDetails['company'],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${widget.studioDetails['role']} Photographer',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${widget.studioDetails['startingPrice']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.yellow, size: 16),
                                      Text(
                                        '4.5',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Address Section
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${widget.studioDetails['addressLine1']}\n${widget.studioDetails['addressLine2']}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Contact Section
                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                widget.studioDetails['phone'],
                                style: TextStyle(fontSize: 14),
                              ),
                              Spacer(),
                              ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.map,color: Colors.white,),
                            label: Text('View on Map',style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                            ],
                          ),
                    
                          
                          SizedBox(height: 16),
                          // Image Carousel Section
                          Container(
                            height: 100,
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.builder(
                              itemCount: 5,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Image.asset(
                                    'asset/image/image1.jpg',
                                    width: 100,
                                    height: 100,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 16),
                          // About Us Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About us',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                widget.studioDetails['Description'],
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Buttons Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.chat, color: Colors.white),
                                label: Text('Get in Touch', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                   shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.book_online, color: Colors.white),
                                label: Text(
                                  'Book Now',
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                   shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                                  backgroundColor: Colors.blue[900],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
