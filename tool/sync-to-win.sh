#!/bin/bash

APP_NAME=counter
APP_DIR="$HOME/Dev/Summit/$APP_NAME"
TARGET_DIR="/mnt/d/Summit/$APP_NAME"

while inotifywait -r -e modify,create,delete "$APP_DIR"; do 
	rsync -avP "$APP_DIR/" "$TARGET_DIR" --exclude=".dart_tool/" --exclude="android" --exclude="build"  --exclude="ios"  --exclude="linux"  --exclude="macos"  --exclude="web"
done