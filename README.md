# Gaussian Splatting Pipeline

An end-to-end pipeline that turns a short handheld video into a trained 3D Gaussian Splatting reconstruction - from raw footage to camera pose estimation to a rendered flythrough - wrapped in a single automated script.

Built as a self-directed learning project to explore 3D Gaussian Splatting, extending my background in point cloud processing, multi-sensor calibration, and 3D geometry from autonomous perception work.

## Demo



https://github.com/user-attachments/assets/d384bd2f-19e1-49da-a6b1-60fc67c6eb52

*(reconstructed from ~2 minutes of handheld phone video)*

## Pipeline

```
video (.mp4)
   │  ffmpeg - extract frames
   ▼
image set (~150-300 frames)
   │  COLMAP (via nerfstudio ns-process-data) - feature matching + camera pose estimation
   ▼
posed images (transforms.json)
   │  nerfstudio ns-train splatfacto - iterative Gaussian Splatting optimization
   ▼
trained 3D Gaussian Splat model
   │  ns-render - camera path rendering
   ▼
flythrough video
```

## Stack

- [nerfstudio](https://docs.nerf.studio/) (`splatfacto` / gsplat backend)
- COLMAP - structure-from-motion / camera pose estimation
- PyTorch + CUDA 11.8
- ffmpeg - video preprocessing
- Run locally on an RTX 3060 laptop GPU via WSL2 (Ubuntu on Windows)

## Usage

```bash
git clone https://github.com/Pruthvi-Radadiya/gaussian-splatting-pipeline.git
cd gaussian-splatting-pipeline
chmod +x run_pipeline.sh
./run_pipeline.sh path/to/your_video.mp4 scene_name
```

This runs the full pipeline: frame extraction → COLMAP pose estimation → Gaussian Splatting training → prints the trained config path. See `run_pipeline.sh` for the individual steps if you want to run/tune them separately (e.g. adjusting `--pipeline.datamanager.camera-res-scale-factor` for lower-VRAM GPUs).

**Requirements:** NVIDIA GPU (6GB+ VRAM), nerfstudio installed (see [installation docs](https://docs.nerf.studio/quickstart/installation.html)), COLMAP.

## What I learned

- Reconstruction quality is bottlenecked far more by **capture quality** (overlap, motion blur, lighting consistency) than by training hyperparameters - a bad COLMAP registration rate (<85%) shows up as artifacts no amount of extra training fixes.
- Concrete tradeoff observed: halving input resolution (`camera-res-scale-factor 0.5`) cut VRAM usage enough to avoid OOM on a 6GB laptop GPU, at a modest cost to fine detail sharpness.
- Camera pose accuracy from COLMAP directly determines splat quality - garbage poses in, garbage splats out.

## Next steps

- Automate a capture-quality check (registration rate threshold) before kicking off training, so bad captures fail fast instead of wasting a training run.
- Explore cloud/Kubernetes deployment for scaled batch processing of multiple scenes.
- Evaluate NVIDIA Isaac Sim / Omniverse import of trained splats for simulation use cases.

## License

MIT
