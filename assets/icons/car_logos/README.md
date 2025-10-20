# Car Manufacturer Logos

This directory can contain local car manufacturer logo images that will be used as the primary source before falling back to external CDN services.

## File Naming Convention

Logo files should be named using the lowercase manufacturer name with no spaces:

- `toyota.png` for Toyota
- `honda.png` for Honda
- `mercedes.png` for Mercedes-Benz
- `bmw.png` for BMW
- etc.

## Supported Formats

- PNG format recommended for transparency support
- File size should be optimized (< 50KB per logo recommended)

## CDN Fallback

If a local logo is not found, the app will automatically fetch logos from external CDN services:

1. Primary: `carlogos.org` - A reliable free CDN for car manufacturer logos
2. Fallback: GitHub repository with car logos dataset

## Adding New Logos

To add a new car brand logo:

1. Download the manufacturer's official logo (PNG format preferred)
2. Optimize the image size
3. Name it according to the convention above (lowercase, no spaces)
4. Place it in this directory
5. The app will automatically use it

## Current Status

Currently using external CDN services. You can add local logos for faster loading and offline support.
