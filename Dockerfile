ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH

ENV APP_PATH="/usr/src"

# 复制压缩包到临时目录
COPY hahub.tar.gz /tmp/

# 根据架构选择正确的二进制文件
RUN \
    FILE_NAME="hahub.tar.gz" && \
    tar -xzf /tmp/${FILE_NAME} -C ${APP_PATH} && \
    echo "Copied ${FILE_NAME} to ${APP_PATH}"

# 复制启动脚本
COPY run.sh /
RUN chmod a+x /run.sh

# 确保可执行文件具有执行权限
RUN chmod a+x ${APP_PATH}/hahub

CMD ["/run.sh"]