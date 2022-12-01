FROM nvidia/cuda:11.5.1-cudnn8-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
    build-essential \
    cmake \
    curl \
    gcc \
    git \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libgtk2.0-dev \
    locales \
    net-tools \
    wget \
    libgl1-mesa-glx \
    zsh \
    parallel \
    sudo \
    nano \
    vim \
    libssl-dev \
    libffi-dev \
    zlib1g-dev 

RUN type -p curl >/dev/null || apt install curl -y
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt-get update
RUN apt-get install -y gh

RUN rm -rf /var/lib/apt/lists/*

ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

ENV LANG=en_US.UTF-8
RUN locale-gen en_US.UTF-8

ARG USER_ID
ARG GROUP_ID

RUN addgroup --gid $GROUP_ID ml
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID ml

RUN usermod -a -G sudo ml 
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ml
WORKDIR /home/ml

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true
ENV ZSH_THEME agnoster
ENV SHELL /bin/zsh

RUN curl https://pyenv.run | bash
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
RUN echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
RUN echo 'eval "$(pyenv init -)"' >> ~/.zshrc

ENV HOME="/home/ml"
ENV PYENV_ROOT="${HOME}/.pyenv"
ENV PATH="${PYENV_ROOT}/shims:${PYENV_ROOT}/bin:${PATH}"

ENV PYTHON_VERSION=3.11.0
RUN pyenv install ${PYTHON_VERSION}
RUN pyenv global ${PYTHON_VERSION}