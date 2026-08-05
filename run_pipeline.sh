#!/bin/bash
set -e

VIDEO=$1
SCENE_NAME=$2
SCALE_FACTOR=${3:-0.5}

RAW_DIR="raw_data/$SCENE_NAME"
DATA_DIR="data/$SCENE_NAME"

echo "Extracting frames to $RAW_DIR..."
mkdir -p $RAW_DIR
ffmpeg -i $VIDEO -vf fps=2 $RAW_DIR/frame_%04d.png

echo "Processing camera poses and point clouds into $DATA_DIR..."
ns-process-data images --data $RAW_DIR --output-dir $DATA_DIR

echo "Starting training on $DATA_DIR (Scale: $SCALE_FACTOR)..."
ns-train splatfacto --data $DATA_DIR --pipeline.datamanager.camera-res-scale-factor $SCALE_FACTOR --viewer.quit-on-train-completion True

CONFIG=$(find outputs/$SCENE_NAME -name config.yml | sort | tail -1)
echo "========================================="
echo "Trained. Config at: $CONFIG"
echo "Use the viewer's render panel to generate your flythrough command."
