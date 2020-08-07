FROM ubuntu:20.04 AS builder

LABEL maintainer="Navan Chauhan <navanchauhan@gmail.com>" \
        org.label-schema.name="Curie Module" \
        org.label-schema.description="https://navanchauhan.github.io/Curie"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    git \
    libopenbabel-dev \
    libopenbabel6 \
    pymol \
    python3-distutils \
    python3-lxml \
    python3-openbabel \
    python3-pymol \
    python3-pip \
    openbabel \
    autodock-vina \
    pandoc \
    texlive-xetex \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# copy PLIP source code
WORKDIR /src
COPY plip/ plip/
RUN chmod +x plip/plipcmd.py
ENV PYTHONPATH $PYTHONPATH:/src

# execute tests
#WORKDIR /src/plip/test
#RUN chmod +x run_all_tests.sh
#RUN ./run_all_tests.sh
#WORKDIR /

# scripts
WORKDIR /src
COPY scripts/ scripts/
RUN chmod +x /src/scripts/main.sh
RUN python3 -m pip install untangle tabulate


# set entry point to plipcmd.py
#ENTRYPOINT  ["python3", "/src/plip/plipcmd.py"]
ENTRYPOINT [ "/src/scripts/main.sh" ]
