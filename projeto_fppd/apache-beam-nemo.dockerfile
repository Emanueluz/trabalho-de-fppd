# Usando uma imagem base do Python 3.9
FROM python:3.9-slim AS python-base

# Usando uma imagem base Debian para instalar Java e outras dependências
FROM debian:bookworm AS build-base

# Instalar OpenJDK 17, Git, Maven, e Gradle
RUN apt-get update && \
    apt-get install -y \
    openjdk-17-jdk \
    git \
    maven \
    gradle \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Crie o diretório /nemo e clone o repositório
RUN mkdir -p /nemo && \
    git clone https://github.com/apache/incubator-nemo.git /nemo

# Definir a variável de ambiente JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk-amd64
ENV PATH $JAVA_HOME/bin:$PATH

# Mude para o diretório /nemo, configure o Gradle Wrapper e construa o projeto
WORKDIR /nemo
FROM gradle:7.5-jdk17 AS build

RUN chmod +x gradlew && \
    ./gradlew wrapper --gradle-version 7.5 && \
    ./gradlew clean shadowJar

# Criar uma nova imagem para a parte Python
FROM python:3.9-slim

# Definir variáveis de ambiente para o Nemo
ENV NEMO_HOME=/nemo
ENV PATH=$PATH:$NEMO_HOME/bin

# Copiar os artefatos construídos e o repositório clonado da imagem build-base
COPY --from=build-base /nemo /nemo

# Instalar Apache Beam e outras dependências necessárias
RUN pip install apache-beam[gcp] apache-beam[interactive]

# Definir o diretório de trabalho
WORKDIR /app

# Copiar a aplicação Python para o diretório de trabalho
COPY . /app

# Comando para executar o Apache Beam com Apache Nemo
CMD ["python", "your_beam_pipeline.py"]
