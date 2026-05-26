# Build on top of the official Coqui TTS image.
# PyTorch is not included in the base image by design (coqui-tts >= 0.27.4),
# Install the CUDA 12.8 variant here for GPU-accelerated voice cloning.
FROM ghcr.io/idiap/coqui-tts:latest

# Install FFmpeg — required by torchcodec for audio decoding
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg && rm -rf /var/lib/apt/lists/*

# Install PyTorch with CUDA 12.8 support
RUN uv pip install torch torchaudio torchcodec --torch-backend=cu128

# Expose the TTS server port
EXPOSE 5002

# Start the TTS server with XTTS v2 voice cloning model
ENTRYPOINT ["tts-server"]
CMD ["--model_name", "tts_models/multilingual/multi-dataset/xtts_v2", "--device", "cuda"]
