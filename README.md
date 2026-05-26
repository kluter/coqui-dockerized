# coqui-dockerized

A fully working, GPU-accelerated Docker setup for voice cloning using [Coqui TTS](https://github.com/idiap/coqui-ai-TTS).

Drop in a voice sample, run one command, start cloning.

---

## Why This Exists

The official Coqui TTS image (`ghcr.io/idiap/coqui-tts`) is intentionally minimal. Starting from version `0.27.4`, PyTorch is no longer bundled - users are expected to install the variant that matches their hardware (CUDA, CPU, ROCm). This is a reasonable design decision, but it means the base image alone won't run.

Several other dependencies are also missing from the base image. This project patches all of that and wires everything together so the path from zero to a working voice clone is a single `docker compose up`.

---

## Built On

This image extends the official Coqui TTS image. All credit for the underlying TTS engine, models, and architecture goes to the Idiap Research Institute and the Coqui community:

**[idiap/coqui-ai-TTS](https://github.com/idiap/coqui-ai-TTS)**

---

## Structure

```
coqui-dockerized/
├── Dockerfile          # extends the base image with PyTorch + FFmpeg
├── compose.yaml        # wires GPU passthrough, volumes, and server config
├── .gitignore
├── README.md
├── models/             # XTTS v2 model cache - gitignored, ~1.8GB on first run
├── voices/             # place voice WAV samples here - gitignored
└── output/             # generated audio lands here - gitignored
```

---

## What This Repo Adds

The base image requires the following to actually work. None of which are included out of the box:

| What | Why |
|---|---|
| `torch`, `torchaudio`, `torchcodec` (cu128) | PyTorch intentionally excluded from base image since v0.27.4 |
| `ffmpeg` | Required by torchcodec for audio decoding, not installed in base image |
| `COQUI_TOS_AGREED=1` | XTTS v2 prompts for license agreement interactively, breaks headless containers |
| `--device cuda` | `--use_cuda` flag is deprecated, replaced with `--device cuda` |

---

## Requirements

- Docker Desktop with WSL2 backend
- NVIDIA GPU with drivers installed
- Docker GPU passthrough working (`docker run --gpus all nvidia/cuda:... nvidia-smi` should succeed)

---

## Quick Start

**1. Clone the repo**

```bash
git clone https://github.com/kluter/coqui-dockerized.git
cd coqui-dockerized
```

**2. Add a voice sample**

Drop a `.wav` file into the `voices/` folder. For best results:
- 15–20 seconds of clean speech
- Single speaker, no background noise
- 22050 Hz mono

```bash
ffmpeg -i your_recording.opus -ar 22050 -ac 1 voices/speaker.wav
```

**3. Build and run**

```bash
docker compose build
docker compose up
```

First run downloads the XTTS v2 model (~1.8GB) into `models/` - this only happens once.

**4. Open the web UI**

Navigate to `http://localhost:5002`

- Set **Reference audio** to `/voices/your_file.wav`
- Choose a language
- Type your text and hit **Speak**

Generated audio plays in the browser. Output saving is not yet automatic - see Roadmap.

---

## Model

**XTTS v2** - a zero-shot multilingual voice cloning model. No training required. A short audio clip is enough to clone a voice on the fly.

Supports 17 languages including English, German, French, Spanish, Polish, and more.

---

## Potential Roadmap

- [ ] Automatic voice pre-loading on startup from `voices/` folder
- [ ] CPU-only variant for machines without NVIDIA GPU
- [ ] Audio sample preprocessing guide
- [ ] Auto-save generated audio to `output/` folder
- [ ] `compose.yaml` PR contribution to upstream repo

---

## License

This project is a Docker wrapper. The underlying Coqui TTS engine is licensed under [CPML (Coqui Public Model License)](https://coqui.ai/cpml). Non-commercial use only unless you hold a commercial license from Coqui.
