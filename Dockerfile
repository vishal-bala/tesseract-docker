FROM ubuntu:18.04 AS system
ENV OMP_THREAD_LIMIT=1
ENV OMP_NUM_THREADS=1
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -yq \
        gcc \
        g++ \
        autoconf \
        automake \
        libtool \
        pkg-config \
        libpng-dev \
        libjpeg8-dev \
        libtiff5-dev \
        zlib1g-dev \
        libleptonica-dev \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


FROM system AS install
RUN wget "https://github.com/tesseract-ocr/tesseract/archive/4.1.1.tar.gz" && \
    gzip -d 4.1.1.tar.gz && \
    tar -xvf 4.1.1.tar && \
    rm 4.1.1.tar

WORKDIR tesseract-4.1.1
RUN ./autogen.sh && \
    ./configure
RUN make
RUN make install && \
    ldconfig

WORKDIR /
RUN rm -r tesseract-4.1.1

WORKDIR /usr/local/share/tessdata
COPY eng.traineddata eng.traineddata
COPY osd.traineddata osd.traineddata
COPY deu.traineddata deu.traineddata


FROM ubuntu:18.04 as env
WORKDIR /
COPY --from=install /usr/local /usr/local

RUN apt-get update && \
    apt-get upgrade -yq && \
    apt-get install -yq libleptonica-dev tesseract-ocr && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


FROM env as run
ENTRYPOINT ["tesseract"]
