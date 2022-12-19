import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dj_music_app/firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MusicList extends StatefulWidget {
  const MusicList({super.key});

  @override
  State<MusicList> createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  FireBaseService fireBaseService = FireBaseService();
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
@override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
  //fireBaseService.initializeDb();
  List<String> playlist = [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('track',).orderBy('userLiked', descending: true).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            listenPlaylist(snapshot, playlist);
            return Column(
              children: [
                Expanded(
                  child:ListView.builder(
                    shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Text(index.toString()),
                      title: Text(snapshot.data.docs[index]['trackName']+" - "+snapshot.data.docs[index]['artist']),
                      subtitle: Text("Ajouté par "+snapshot.data.docs[index]['name']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          fireBaseService.removeMusic(snapshot.data.docs[index]['name'],snapshot.data.docs[index]['trackName'],snapshot.data.docs[index]['id']);
                        },
                      ),
                    );
                  },
                )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        previousTrack();
                      }, 
                      icon: const Icon(Icons.skip_previous)),
                    initializeIconButton(),
                    IconButton(
                      onPressed: () {
                        skipTrack();
                      }, 
                      icon: const Icon(Icons.skip_next)),
                  ],
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      )    
      );
  }

  IconButton initializeIconButton() {
    return isPlaying ? IconButton(
                onPressed: () {
                    setState(() {
                      isPlaying = true;
                    });
                    audioPlayer.pause();
                }, 
                icon: const Icon(Icons.pause))
                : IconButton( 
                  onPressed: () {
                  audioPlayer.play();
                  }, 
                  icon: const Icon(Icons.play_arrow));
  }

  void listenPlaylist(AsyncSnapshot<dynamic> snapshot, List<String> playlist) {
    for (int i = 0; i < snapshot.data.docs.length; i++) {
      playlist.add(snapshot.data.docs[i]['url']);
    }
      audioPlayer.setAudioSource(ConcatenatingAudioSource(
      children: playlist.map((url) => AudioSource.uri(Uri.parse(url))).toList(),
    ));
    audioPlayer.load();
  }

  void skipTrack() {
    audioPlayer.seekToNext();
  }

  void previousTrack() {
    audioPlayer.seekToPrevious();
  }
}