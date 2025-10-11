# Multi-stage Dockerfile for Flutter Web Application
# Stage 1: Build Flutter web app
FROM ubuntu:22.04 AS build-stage

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_VERSION=3.24.0
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME && \
    flutter --version && \
    flutter config --enable-web && \
    flutter precache --web

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.yaml pubspec.lock ./
COPY packages ./packages

RUN flutter pub get

# Copy the rest of the application
COPY . .

# Build the production web app
RUN flutter build web \
    --release \
    --target lib/main_production.dart \
    --web-renderer auto \
    --base-href /

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx/app.conf /etc/nginx/conf.d/default.conf

# Copy built web app from build stage
COPY --from=build-stage /app/build/web /usr/share/nginx/html

# Add build info
RUN echo "Built on $(date)" > /usr/share/nginx/html/build-info.txt

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

