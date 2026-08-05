# Gaussian Splatting Pipeline

Video in, trained 3D Gaussian Splat out. Built this to actually understand the full pipeline (capture, camera pose estimation, training, rendering) instead of just reading about it.

My background is in multi-sensor calibration and point cloud processing (camera/LiDAR/radar fusion, 3D-2D and 3D-3D projections) from autonomous perception work, so this was a natural next thing to dig into.

## Demo

https://github.com/user-attachments/assets/b4bd633f-37be-48ca-964d-a8f218b5abb8

*(reconstructed from ~2 minutes of handheld phone video)*

## How it works

```
video (.mp4)
   │  ffmpeg: extract frames
   ▼
image set (~150-300 frames)
   │  COLMAP (via nerfstudio ns-process-data): feature matching + camera pose estimation
   ▼
posed images (transforms.json)
   │  nerfstudio ns-train splatfacto: iterative Gaussian Splatting optimization
   ▼
trained 3D Gaussian Splat model
   │  ns-render: camera path rendering
   ▼
flythrough video
```

## Stack

- [nerfstudio](https://docs.nerf.studio/) (`splatfacto` / gsplat backend)
- COLMAP for structure-from-motion / pose estimation
- PyTorch + CUDA 11.8
- ffmpeg for frame extraction
- Trained locally on an RTX 3060 laptop GPU (6GB VRAM) via WSL2

## Usage

```bash
git clone https://github.com/Pruthvi-Radadiya/gaussian-splatting-pipeline.git
cd gaussian-splatting-pipeline
chmod +x run_pipeline.sh
./run_pipeline.sh path/to/your_video.mp4 scene_name
```

Runs the whole thing end to end: frame extraction → COLMAP pose estimation → training → prints the trained config path. Check `run_pipeline.sh` if you want to run steps individually or tune parameters (e.g. `--pipeline.datamanager.camera-res-scale-factor` if you're on a lower-VRAM GPU, I run at 0.5 to fit in 6GB).

**Needs:** NVIDIA GPU (6GB+ VRAM), nerfstudio, COLMAP.

## What I learned

- Capture quality matters way more than training hyperparameters. If COLMAP's registration rate drops below ~85%, no amount of extra training fixes the artifacts. The fix is a better capture, not more compute.
- Downscaling input images to 0.5 was enough to avoid OOM on 6GB VRAM, at a small cost to fine detail.
- Bad camera poses = bad splats. COLMAP's output quality is the real bottleneck, not the splatting itself.

## Next up

- Add a registration-rate check before training so a bad capture fails fast instead of wasting a full run.
- Look at deploying this on Kubernetes for batch processing multiple scenes.
- Try importing trained splats into NVIDIA Isaac Sim / Omniverse.


