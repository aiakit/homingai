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
    FILE_NAME="hahub" && \
    echo "Copying ${FILE_NAME} from project root" && \
    mkdir -p ${APP_PATH} && \
    cp -f /hahub ${APP_PATH}/ || exit 1

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

CMD ["/run.sh"]