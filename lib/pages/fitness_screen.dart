//import 'package:async/async.dart';
//import 'package:heyhealth/services/database.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:heyhealth/localisations/local_lang.dart';

class ChewieListItem extends StatefulWidget {
  // This will contain the URL/asset path which we want to play
  final VideoPlayerController videoPlayerController;
  final bool looping;

  ChewieListItem({
    @required this.videoPlayerController,
    this.looping,
    Key key,
  }) : super(key: key);

  @override
  _ChewieListItemState createState() => _ChewieListItemState();
}

class _ChewieListItemState extends State<ChewieListItem> {
  ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    // Wrapper on top of the videoPlayerController
    _chewieController = ChewieController(
      allowPlaybackSpeedChanging: false,
      allowMuting: false,
      //autoPlay: true,
      showControls: false,
      allowFullScreen: true,
      showControlsOnInitialize: false,
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: 16 / 9,
      // Prepare the video to be played and display the first frame
      autoInitialize: true,
      looping: true,
      // Errors can occur for example when trying to play a video
      // from a non-existent URL

      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.black54,
        onTap: () {
          //print(data);
          setState(() {
            if (_chewieController.isPlaying) {
              _chewieController.pause();
              //_chewieController.exitFullScreen();
            } else {
              _chewieController.play();
              //_chewieController.enterFullScreen();
            }
          });
        },
        child: Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Chewie(
                controller: _chewieController,
              ),
            )));
  }

  @override
  void dispose() {
    super.dispose();
    // IMPORTANT to dispose of all the used resources
    widget.videoPlayerController.dispose();
    _chewieController.dispose();
  }
}

class FitnessScreen extends StatefulWidget {
  @override
  FitnessScreenState createState() {
    return FitnessScreenState();
  }
}

class FitnessScreenState extends State<FitnessScreen> {
  List appointmentlist = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
    );
  }

  Widget videotile() {
    // print(data.data);
    return InkWell(
        splashColor: Colors.black54,
        onTap: () {
          //print(data);
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return AspectRatio(
                  aspectRatio: 0.75,
                  child: VideoPlayer(_controller),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ));
  }

  VideoPlayerController _controller;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://player.vimeo.com/external/406088849.sd.mp4?s=970822df22ddc7eb04af43c00cfe2de410cf1468&profile_id=165&oauth2_token_id=57447761');
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);
    super.initState();
  }
/*
  Future _mydata;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _mydata = _mydocumentdata();
  }

  final AsyncMemoizer _memoizer = AsyncMemoizer();
  Future<dynamic> _mydocumentdata() {
    print('Executed!');
    return this._memoizer.runOnce(() async {
      return await DatabaseService().videoCollection.doc('wellness').get();
    });
  }
  */

  Widget _buildBody(BuildContext context) {
    // const i=0;
    /*
    User user = Provider.of<User>(context);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('patients')
          .doc(user.uid)
          .collection('appointments')
          .orderBy('appointmenttime')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        for (int i = 0; i < snapshot.data.docs.length; i++) {
          // printf('${snapshot.data.documents.length}');
          appointmentlist = snapshot.data.docs.toList();
        }
        */
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10, bottom: 10, left: 5),
              child: Text(
                DemoLocalization.of(context).translate("wellness_video"),
                style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
                child: GridView.count(
                    scrollDirection: Axis.vertical,
                    //crossAxisSpacing: 5,
                    childAspectRatio: 16 / 9,
                    mainAxisSpacing: 8,
                    crossAxisCount: 1,
                    children: <Widget>[
                  //List.generate(
                  //   4,
                  //  (index) {
                  //  return

                  ChewieListItem(
                    videoPlayerController: VideoPlayerController.network(
                      'https://player.vimeo.com/external/372301567.sd.mp4?s=6116141894bff25632e5930f3094baa2c2ca9a85&profile_id=139&oauth2_token_id=57447761',
                    ),
                  ),
                  ChewieListItem(
                    videoPlayerController: VideoPlayerController.network(
                      'https://player.vimeo.com/external/377100374.sd.mp4?s=619b9449685007ccff8022062f5fe12930246e35&profile_id=139&oauth2_token_id=57447761',
                    ),
                  ),
                  ChewieListItem(
                    videoPlayerController: VideoPlayerController.network(
                      'https://player.vimeo.com/external/324591443.sd.mp4?s=4f1c74f2cdec02b5551050b3a6ec56f3ff2b2950&profile_id=164&oauth2_token_id=57447761',
                    ),
                  ),
                ]
                    //   );
                    //return videotile();
                    //  },
                    )),
          ],
        ));
    //},
    //);
  }
}
