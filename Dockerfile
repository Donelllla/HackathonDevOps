FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    nginx \
    libnginx-mod-http-image-filter \
    php-fpm \
    php-gd \
    curl

RUN echo "load_module modules/ngx_http_image_filter_module.so;" > /etc/nginx/modules-enabled/50-mod-http-image-filter.conf

RUN groupadd -g 1000 nginx && \
    useradd -u 1000 -g nginx -s /sbin/nologin -d /var/www nginx

# Копирование конфигов
COPY etc/nginx/conf.d/ /etc/nginx/conf.d/
COPY etc/systemd/system/nginx-log-manager.service /etc/systemd/system/
COPY usr/local/bin/nginx_log_manager.sh /usr/local/bin/

# Копирование веб-контента
COPY var/www/ /var/www/

# Настройка прав
RUN chown -R nginx:nginx /var/www && \
    chmod -R 755 /var/www && \
    chmod +x /usr/local/bin/nginx_log_manager.sh && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log
# Настройка PHP-FPM
# RUN sed -i 's/;clear_env = no/clear_env = no/' /etc/php81/php-fpm.d/www.conf && \

EXPOSE 80 443 8081 8082 8083

CMD ["sh", "-c", "nginx -g 'daemon off;'"]
