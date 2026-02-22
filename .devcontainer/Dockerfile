FROM ubuntu:24.04

ARG KIND_VERSION=v0.29.0
ARG KUBECTL_VERSION=v1.35
ARG KUBEVIRT_VERSION=v1.7.0
ARG ENV_ARCH=linux-amd64
ARG K9S_VERSION=v0.50.18
ARG HELM_VERSION=v4.0.0

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y \
    qemu-system-gui \
    sudo \
    python3-launchpadlib \
    x11-apps \
    apt-transport-https \
    gnupg \
    guestfish \
    bash-completion \
    ca-certificates \
    curl

RUN update-ca-certificates

RUN curl -sLf https://go.dev/dl/go1.23.5.linux-amd64.tar.gz | \
    tar -C /usr/local -xz && \
    ln -sf /usr/local/go/bin/go /usr/local/bin/go

# Install kubectl
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/${KUBECTL_VERSION}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBECTL_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list \
    && sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list \
    && sudo apt-get update \
    && sudo apt-get install -y kubectl

# Install kind
RUN [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64 && \
    chmod +x ./kind && \
    mv ./kind /usr/local/bin/kind

# Install virtctl
RUN curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-${ENV_ARCH} && \
	chmod +x virtctl && \
    install virtctl /usr/local/bin/virtctl

# Install K9S
RUN curl -fsSL -o /tmp/k9s.deb https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_linux_amd64.deb && \
    apt install /tmp/k9s.deb

# Install Helm
RUN curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | tee /etc/apt/sources.list.d/helm-stable-debian.list \
    && apt-get update \
    && apt-get install helm

ENV HOME /home/${REMOTE_USER}

USER ${REMOTE_USER}
