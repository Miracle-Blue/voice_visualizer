part of '../screen/visualizer_screen.dart';

abstract class VisualizerScreenState extends State<VisualizerScreen> with TickerProviderStateMixin {
  Ticker? ticker;

  SoundHandle? soundHandle;
  AudioSource? audioSource;

  ui.FragmentShader? shader2D;
  ui.FragmentShader? shader3D;

  late SoLoud soLoud;
  late VisualizerController viController;
  late Shader2dController shader2dController;

  Future<void> playSound() async {
    audioSource ??= await soLoud.loadAsset('assets/music/skyfall.mp3');
    soundHandle ??= await soLoud.play(audioSource!);

    ticker ??= Ticker((elapsed) {
      viController.update();
      shader2dController.update(elapsed: elapsed);
    })..start().ignore();
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

  Future<void> loadShader() async {
    shader2D ??= (await ui.FragmentProgram.fromAsset('assets/shader/voice_vi_2d.frag')).fragmentShader();
    shader3D ??= (await ui.FragmentProgram.fromAsset('assets/shader/voice_vi_3d.frag')).fragmentShader();

    setState(() {});
  }

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();

    viController = VisualizerController(audioData: AudioData(GetSamplesKind.linear));
    shader2dController = Shader2dController(audioData: AudioData(GetSamplesKind.texture));

    soLoud = SoLoud.instance;
    soLoud.setFftSmoothing(.9);

    loadShader();
  }

  @override
  void dispose() {
    ticker?.stop();
    ticker?.dispose();
    ticker = null;

    shader2dController.dispose();
    viController.dispose();

    super.dispose();
  }

  /* #endregion */
}
