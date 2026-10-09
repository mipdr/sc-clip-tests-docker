# SC-Clip Test Environment Docker Image
# Pre-installed with SuperCollider, JACK, and all dependencies for fast CI

FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive \
    QT_QPA_PLATFORM=offscreen \
    DISPLAY=:99

# Install all dependencies in a single layer to minimize image size
RUN apt-get update && apt-get install -y \
    # SuperCollider packages
    supercollider-language \
    supercollider-server \
    supercollider-common \
    supercollider-supernova \
    # Audio dependencies
    jackd2 \
    libjack-jackd2-0 \
    libsndfile1 \
    libfftw3-3 \
    libasound2 \
    libavahi-client3 \
    # Display/GUI dependencies (for headless mode)
    xvfb \
    libxt6 \
    # Utilities
    software-properties-common \
    wget \
    unzip \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Verify SuperCollider installation
RUN sclang -v 2>&1 | head -5 || (echo "ERROR: sclang not found" && exit 1)

# Pre-install ddwMixerChannel quark
# Create a minimal script to install the quark
RUN mkdir -p /tmp/quark-install && \
    echo 'Quarks.install("https://github.com/jamshark70/ddw-mixerchannelgui"); 0.exit;' > /tmp/quark-install/install-quarks.scd && \
    timeout 120 sclang -D /tmp/quark-install/install-quarks.scd || echo "Quark installation attempted" && \
    rm -rf /tmp/quark-install

# Remove GUI-dependent Document extensions that cause headless issues
RUN QUARKS_DIR="/root/.local/share/SuperCollider/downloaded-quarks" && \
    if [ -f "$QUARKS_DIR/ddwGUIEnhancements/Document-scanFor.sc" ]; then \
        rm "$QUARKS_DIR/ddwGUIEnhancements/Document-scanFor.sc" && \
        echo "Removed GUI-dependent Document extensions"; \
    fi

# Create extensions directory
RUN mkdir -p /root/.local/share/SuperCollider/Extensions

# Create sclang_conf.yaml to include user Extensions directory
RUN mkdir -p /root/.config/SuperCollider && \
    echo 'includePaths:' > /root/.config/SuperCollider/sclang_conf.yaml && \
    echo '  - /root/.local/share/SuperCollider/Extensions' >> /root/.config/SuperCollider/sclang_conf.yaml && \
    echo 'excludePaths: []' >> /root/.config/SuperCollider/sclang_conf.yaml && \
    echo 'postInlineWarnings: false' >> /root/.config/SuperCollider/sclang_conf.yaml

# Set working directory
WORKDIR /workspace

# Default command (can be overridden)
CMD ["/bin/bash"]
