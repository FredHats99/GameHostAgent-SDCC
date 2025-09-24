FROM golang:1.22 AS build

WORKDIR /app
COPY . .

RUN go mod init gamehostagent && go mod tidy
RUN go build -o game-host-agent main.go

FROM debian:bookworm-slim
# Install gstreamer and uinput deps
RUN apt-get update && apt-get install -y \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libgstreamer1.0-dev \
    libudev-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/game-host-agent /game-host-agent

CMD ["/game-host-agent"]
