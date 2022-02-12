FROM python:3.10.2-slim-bullseye

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH /usr/local/bin:$PATH
ENV LANG C.UTF-8

RUN set -eux ; \
    \
    pythonAptMark="$(apt-mark showmanual)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        build-essential \
        cmake \
        git-core \
        libass-dev \
        libfreetype6-dev \
        libtool \
        libvorbis-dev \
        pkg-config \
        texinfo \
        wget \
        zlib1g-dev \
        libsdl2-dev \
        libva-dev \
        libvdpau-dev \
        libxcb1-dev \
        libxcb-shm0-dev \
        libxcb-xfixes0-dev \
        nasm \
        yasm \
        libx264-dev \
        libnuma-dev \
        libx265-dev \
        libvpx-dev \
        #libfdk-aac-dev \
        libmp3lame-dev \
        libopus-dev \
        libaom-dev \
        libogg-dev \
        libtheora-dev \
        libssl-dev \
        \
    ; \
    cd /tmp; \
    wget https://downloads.sourceforge.net/opencore-amr/fdk-aac-2.0.2.tar.gz; \
    tar xzvf fdk-aac-2.0.2.tar.gz; \
    cd fdk-aac-2.0.2; \
    ./configure --disable-static; make; make install; \
    cd /tmp && \
    git -C SVT-AV1 pull 2> /dev/null || git clone https://github.com/AOMediaCodec/SVT-AV1.git; \
    mkdir -p SVT-AV1/build; \
    cd SVT-AV1/build; \
    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DBUILD_DEC=OFF -DBUILD_SHARED_LIBS=OFF ..; \
    make -j4; \
    make install; \
    ldconfig; \
    cd /tmp; \
        wget -O ffmpeg-5.0.tar.bz2 https://ffmpeg.org/releases/ffmpeg-5.0.tar.bz2; \
        tar xjvf ffmpeg-5.0.tar.bz2; \
        cd ffmpeg-5.0; \
        ./configure \
        --pkg-config-flags="--static" \
        --disable-ffplay \
        --extra-libs="-lpthread -lm" \
        --enable-gpl \
        --enable-libaom \
        --enable-libass \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libopus \
        --enable-libsvtav1 \
        --enable-libvorbis \
        --enable-libvpx \
        --enable-libtheora \
        --enable-libx264 \
        --enable-libx265 \
        --enable-openssl \
        --enable-nonfree \
        ; \
        make -j4 ; \
        make install ; \
        hash -r ; \
    rm -rf /tmp/*; \
    ldconfig; \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $pythonAptMark; \
    echo $pythonAptMark > /tmp/lists.txt; \
    find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
        | awk '/=>/ { print $(NF-1) }' \
        | sort -u \
        | xargs -r dpkg-query --search \
        | cut -d: -f1 \
        | sort -u \
        | xargs -r apt-mark manual \
    ; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*
RUN pip install -U pip; \
    pip install -U setuptools wheel; \
    pip install numpy Pillow lxml piexif ffmpeg-python structlog

CMD ["bash"]
