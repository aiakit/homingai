ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG HAHUB_VERSION

ENV APP_PATH="/usr/src"

# 根据架构选择正确的二进制文件
RUN \
    case "$BUILD_ARCH" in \
        "aarch64") MACHINE="arm64" ;; \
        "amd64")   MACHINE="amd64" ;; \
        "armhf")   MACHINE="arm" ;; \
        "armv7")   MACHINE="arm" ;; \
        "i386")    MACHINE="386" ;; \
        *) echo "Unsupported architecture: $BUILD_ARCH" && exit 1 ;; \
    esac && \
    echo "Architecture: $BUILD_ARCH, Machine: $MACHINE" && \
    FILE_NAME="hahub_${HAHUB_VERSION}_linux_${MACHINE}.tar.gz" && \
    FILE_DIR="hahub_${HAHUB_VERSION}_linux_${MACHINE}" && \
    echo "File: $FILE_NAME" && \
    echo "Downloading: https://github.com/aiakit/hahub/releases/download/${HAHUB_VERSION}/${FILE_NAME}" && \
    curl -L -o /tmp/${FILE_NAME} \
        "https://github.com/aiakit/hahub/releases/download/${HAHUB_VERSION}/${FILE_NAME}" || exit 1 && \
    mkdir -p ${APP_PATH} && \
    tar xzf /tmp/${FILE_NAME} -C /tmp || exit 1 && \
    cp -f /tmp/${FILE_DIR}/hahub ${APP_PATH}/ || exit 1 && \
    cp -rf /tmp/${FILE_DIR}/web ${APP_PATH}/ || exit 1 && \
    rm -rf /tmp/${FILE_NAME} /tmp/${FILE_DIR}

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]