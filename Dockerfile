ARG CUDA_VERSION=13.0.0

FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu24.04 AS build

ARG BASALT_REF=main
ARG BUILD_JOBS=6
ARG APP_UID=1000
ARG APP_GID=1000

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        python3 \
        python3-pip \
        python3-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
RUN git clone --depth 1 --branch "${BASALT_REF}" \
        https://github.com/jesdga95/basalt.git /src

RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt \
    && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --parallel "${BUILD_JOBS}" \
    && rm -rf build .git

FROM nvidia/cuda:${CUDA_VERSION}-runtime-ubuntu24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    HOME=/home/basalt \
    PATH=/opt/venv/bin:$PATH

ARG APP_UID=1000
ARG APP_GID=1000

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        libgomp1 \
        libstdc++6 \
        python3 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/basalt \
    && chown "${APP_UID}:${APP_GID}" /home/basalt

COPY --from=build /opt/venv /opt/venv
COPY --from=build /src /src

WORKDIR /src
USER ${APP_UID}:${APP_GID}

ENTRYPOINT ["bin/basalt", "serve", "--config", "/config/basalt_config.json"]
