FROM postgres:11

RUN apt update \
 && apt install -y \
        curl \
        gdal-bin \
        iconv \
        sudo \
        unzip \
        wget \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /geocoder
COPY . .
VOLUME ["/geocoder/data"]
