# SC-Clip Tests Docker Image

Pre-built Docker image containing SuperCollider, JACK, and all dependencies needed for running sc-clip tests in CI.

## Purpose

This image significantly speeds up CI test runs by pre-installing all dependencies (~2-3 minutes of installation time saved per run).

## What's Included

- **SuperCollider**: language, server, supernova
- **JACK**: jackd2 audio server
- **Audio libraries**: libsndfile, libfftw3, libasound2
- **Display**: Xvfb for headless GUI
- **Quarks**: ddwMixerChannel pre-installed
- **Utilities**: git, wget, unzip

## Image Location

```
ghcr.io/mipdr/sc-clip-tests-docker:latest
```

## Usage in GitHub Actions

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/mipdr/sc-clip-tests-docker:latest
      options: --user root

    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          # Your tests here
          sclang test.scd
```

## Local Testing

```bash
# Pull the image
docker pull ghcr.io/mipdr/sc-clip-tests-docker:latest

# Run interactively
docker run -it --rm \
  -v $(pwd):/workspace \
  ghcr.io/mipdr/sc-clip-tests-docker:latest \
  bash

# Run tests
docker run --rm \
  -v $(pwd):/workspace \
  ghcr.io/mipdr/sc-clip-tests-docker:latest \
  sclang /workspace/Tests/test_save_load_simple.scd
```

## Building Locally

```bash
docker build -t sc-clip-tests:local .
```

## Updating

The image is automatically rebuilt and published when:
- Dockerfile is modified
- Manually triggered via GitHub Actions workflow_dispatch

To trigger a rebuild: Actions → Build and Publish Docker Image → Run workflow
