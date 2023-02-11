FROM ubuntu:jammy

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install --no-install-recommends \
    ffmpeg git curl \
    build-essential \
    git \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

#RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

RUN pip3 install -U pip setuptools \
    && pip3 install --upgrade --force-reinstall git+https://github.com/openai/whisper.git \
    && pip3 install -U setuptools-rust

RUN python3 -c "import whisper; print(whisper._download(whisper._MODELS['tiny'], '$HOME/.cache/whisper', False))" 
RUN python3 -c "import whisper; print(whisper._download(whisper._MODELS['small'], '$HOME/.cache/whisper', False))" 
RUN python3 -c "import whisper; print(whisper._download(whisper._MODELS['medium'], '$HOME/.cache/whisper', False))" 
RUN python3 -c "import whisper; print(whisper._download(whisper._MODELS['large'], '$HOME/.cache/whisper', False))" 

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

RUN $HOME/.cargo/bin/cargo install --locked pueue

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install --no-install-recommends \
    unzip bash \
    && rm -rf /var/lib/apt/lists/*

RUN curl https://rclone.org/install.sh | bash

WORKDIR /app

#COPY . /app

CMD tail -f /dev/null

