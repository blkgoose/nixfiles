{ pkgs, ... }:
let
  app = pkgs.runCommand "transcriber" { } ''
    mkdir -p $out
    cp ${./worker.py} $out/worker.py
  '';

  python = pkgs.python3.withPackages (ps: [
    ps.sherpa-onnx
    ps.numpy
  ]);

  whisperModels = {
    "large-v3-turbo" = pkgs.fetchurl {
      url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo.bin";
      hash = "sha256-H8cPd0046xaZk6w5Huo1fvR8iHV+9y7llDh5t+jivGk=";
    };
  };

  vadModel = pkgs.fetchurl {
    url = "https://huggingface.co/ggml-org/whisper-vad/resolve/main/ggml-silero-v5.1.2.bin";
    hash = "sha256-KZQNmNQrkfvQXOSJ8+z3xy8KQvAn5IdZGaKPtMBOos8=";
  };

  segmentationModel = pkgs.fetchzip {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/speaker-segmentation-models/sherpa-onnx-pyannote-segmentation-3-0.tar.bz2";
    hash = "sha256-hqaCTZJKZp6IHxYzgVBd9Bss6wC1qg+edB/v10BT1tA=";
  };

  embeddingModel = pkgs.fetchurl {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/speaker-recongition-models/wespeaker_en_voxceleb_resnet34_LM.onnx";
    hash = "sha256-6YSFY9qG8mMRcTTf161jySNVs33kkrVeMlQAydnDkBI=";
  };
in
{
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.user == "transcriber" &&
          (action.id == "org.freedesktop.login1.inhibit-block-sleep" ||
           action.id == "org.freedesktop.login1.inhibit-block-idle")) {
        return polkit.Result.YES;
      }
    });
  '';

  systemd.services.transcriber = {
    description = "Whisper transcription worker";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [
      pkgs.ffmpeg-headless
      pkgs.systemd
      pkgs.coreutils
    ];
    environment = {
      SERVER_URL = "http://192.168.1.101:8086";
      WORK_DIR = "/var/lib/transcriber/work";
      XDG_CACHE_HOME = "/var/lib/transcriber/cache";
      VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";
      WHISPER_CLI = "${pkgs.whisper-cpp-vulkan}/bin/whisper-cli";
      WHISPER_MODELS = builtins.toJSON (builtins.mapAttrs (_: toString) whisperModels);
      VAD_MODEL = "${vadModel}";
      DIARIZATION_THREADS = "16";
      SEGMENTATION_MODEL = "${segmentationModel}/model.onnx";
      EMBEDDING_MODEL = "${embeddingModel}";
    };
    serviceConfig = {
      ExecStart = "${python}/bin/python3 ${app}/worker.py";
      DynamicUser = true;
      StateDirectory = "transcriber";
      SupplementaryGroups = [
        "render"
        "video"
      ];
      Restart = "on-failure";
    };
  };
}
