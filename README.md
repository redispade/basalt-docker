# Basalt in Docker

This setup builds Basalt in a CUDA 13 development image, then runs it from a
separate CUDA runtime image. The source checkout happens during the image
build; no Basalt source tree is needed in this workspace.

## Requirements

- Linux x86-64 with an NVIDIA Blackwell GPU (compute capability 12.0).
- Docker Engine, Docker Compose, and NVIDIA Container Toolkit configured for
  Docker.
- Enough system RAM and disk space for the model. The model itself is not
  included in the image.

## Configure and run

1. Copy `.env.example` to `.env` and set `BASALT_API_KEY` to a strong secret.
   On Linux, set `LOCAL_UID` and `LOCAL_GID` to the IDs that own this
   workspace if they differ from `1000`.
2. Put a Basalt `.basalt` model at `./models/model.basalt`, or edit the model
   path in `basalt_config.json` to match your local file.
3. Build and start the service:

   ```sh
   mkdir -p models cache
   docker compose up --build
   ```

The API and web UI are available at <http://localhost:8080>. The port is
published only on the host's loopback interface, and the configured API key is
required by the server.

`./models` is mounted read-only. Models must be downloaded manually to this folder.
Change `- /root/models:/models:ro` to `- ./models:/models:ro` or to your preferred model folder in docker-compose.yml
`./cache` persists Basalt's runtime cache, and the configuration file is mounted read-only.
All host paths are relative to this workspace.

## Build controls

- `BASALT_REF` selects the upstream branch or tag (default: `main`).
- `BUILD_JOBS` controls the parallel build jobs (default: `16`, one per
  physical core on a 16-core host; set it to `32` to use all logical threads).

For example, set either value in `.env`, then rebuild with
`docker compose up --build`.

Basalt's build and runtime requirements are documented in the upstream
[README](https://github.com/jesdga95/basalt#requirements),
[building guide](https://github.com/jesdga95/basalt/blob/main/docs/building.md),
[running guide](https://github.com/jesdga95/basalt/blob/main/docs/running.md),
and [configuration reference](https://github.com/jesdga95/basalt/blob/main/docs/configuration/index.md).

## License

The Dockerfile, `docker-compose.yml`, `basalt_config.json`, `.env.example` and
the docs in this repository are MIT — see [LICENSE](LICENSE).

What they run is someone else's:

- [Basalt](https://github.com/jesdga95/basalt) is MIT. It in turn includes
  Strata (MIT), ggml and llama.cpp (MIT), stb_image (MIT) and Infernix
  (Apache-2.0). See its `THIRD_PARTY_LICENSES`.
- The `.basalt` model files are **not** MIT. They derive from
  Qwen3.8-Flash-Next is distributed under the
  [Qwen Community License 1.0](https://huggingface.co/jesdga/Qwen3.8-Flash-Next-Basalt/blob/main/LICENSE)
- The GSQ-RCO quants come from
  [ISTA-DASLab](https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF)
  (IST Austria). Citing [GSQ](https://arxiv.org/abs/2604.18556) and
  [RCO](https://arxiv.org/abs/2605.00649) is requested.
