part of '../screen/visualizer_screen.dart';

abstract class VisualizerScreenState extends State<VisualizerScreen> with TickerProviderStateMixin {
  Ticker? ticker;

  SoundHandle? soundHandle;
  AudioSource? audioSource;

  late SoLoud soLoud;
  late VisualizerController viController;

  Future<void> playSound() async {
    audioSource ??= await soLoud.loadAsset('assets/music/skyfall.mp3');
    soundHandle ??= await soLoud.play(audioSource!);

    ticker ??= Ticker((_) => viController.update())..start().ignore();
  }

  Future<void> stopSound() async {
    if (soundHandle != null) {
      await soLoud.stop(soundHandle!);
      soundHandle = null;
    }

    ticker?.stop();
    ticker?.dispose();
    ticker = null;
  }

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();

    viController = VisualizerController(audioData: AudioData(GetSamplesKind.linear));

    soLoud = SoLoud.instance;
    soLoud.setFftSmoothing(.95);
  }

  @override
  void dispose() {
    ticker?.stop();
    ticker?.dispose();
    ticker = null;

    viController.dispose();

    super.dispose();
  }

  /* #endregion */
}
