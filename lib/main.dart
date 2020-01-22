import 'dart:async';

import 'package:flutter/material.dart';
import 'musique.dart';
import 'package:audioplayer/audioplayer.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Coda Music",
      theme: new ThemeData(
        primaryColor: Colors.grey[900]
      ),
      debugShowCheckedModeBanner: false,
      home: new Home(),
    );
  }

}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _Home();
  }
}

class _Home extends State<Home> {

  List<Musique> maListeDeMusiques = [
    new Musique("theme Swift", "Codabee", "images/un.jpg", "https://codabee.com/wp-content/uploads/2018/06/un.mp3"),
    new Musique("theme Flutter", "Codabee", "images/deux.jpg", "https://codabee.com/wp-content/uploads/2018/06/deux.mp3"),
  ];

  int index = 0;
  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Musique maMusiqueActuelle;
  Duration position = new Duration(seconds: 0);
  Duration duree = new Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Coda Music")
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Card(
              elevation: 9.0,
              child: new Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: new Image.asset(maMusiqueActuelle.imagePath),
              )
          ),
          textAvecStyle(maMusiqueActuelle.titre, 1.5),
          textAvecStyle(maMusiqueActuelle.artiste, 1.0),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              bouton(Icons.fast_rewind, 30.0, ActionMusic.rewind),
              bouton((statut == PlayerState.playing) ?Icons.pause : Icons.play_arrow, 45.0,(statut == PlayerState.playing) ? ActionMusic.pause : ActionMusic.play),
              bouton(Icons.fast_forward, 30.0, ActionMusic.forward),
            ],
          ),
          new Slider(
              value: position.inSeconds.toDouble(),
              max: 22.0,
              min: 0.0,
              inactiveColor: Colors.white,
              activeColor: Colors.red,
              onChanged: (double d) {
                setState(() {
                  audioPlayer.seek(d);
                });
              }
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              textAvecStyle(fromDuration(position), 0.8),
              textAvecStyle(fromDuration(duree), 0.8)
            ],
          ),
        ],
      ),
      backgroundColor: Colors.grey[800]
    );
  }
  
  Text textAvecStyle(String data, double scale){
    return new Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: new TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic
      ),
    );
  }

  void configurationAudioPlayer() {
    audioPlayer = new AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged.listen(
        (pos) => setState(() => position = pos)
    );
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlayer.duration;
        });
      } else if(state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print("erreur : $message");
      setState(() {
        statut = PlayerState.stopped;
        duree = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    }
    );
  }

  Future play() async {
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward(){
    if(index == maListeDeMusiques.length -1){
      index = 0;
    }
    else {
      index++;
    }
    maMusiqueActuelle = maListeDeMusiques[index];
    audioPlayer.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind() {
    if(position > Duration(seconds: 3)){
      audioPlayer.seek(0.0);
    }
    else{
      if(index == 0){
        index = maListeDeMusiques.length -1;
      }
      else{
        index--;
      }
      maMusiqueActuelle = maListeDeMusiques[index];
      audioPlayer.stop();
      configurationAudioPlayer();
      play();
    }
  }

  String fromDuration(Duration duree){
    return duree.toString().split(".").first;
  }

  IconButton bouton(IconData icone, double taille, ActionMusic action) {
    return new IconButton(
      iconSize: taille,
        color: Colors.white,
        icon: new Icon(icone),
        onPressed: () {
          switch(action){
            case ActionMusic.play:
              play();
              break;
            case ActionMusic.pause:
              audioPlayer.pause();
              pause();
              break;
            case ActionMusic.forward:
              forward();
              break;
            case ActionMusic.rewind:
              rewind();
              break;
          }
        }
        );
  }
}

enum ActionMusic {
  play,
  pause,
  rewind,
  forward
}
enum PlayerState {
  playing,
  stopped,
  paused
}
