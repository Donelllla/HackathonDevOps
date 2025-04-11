FROM debian:bookworm-slim

# Установка Apache и PHP
RUN apt-get update && \
    apt-get install -y \
    apache2 \
    libapache2-mod-php && \
    rm -rf /var/lib/apt/lists/*

# Создаем рабочую директорию
WORKDIR /var/www/html

# Копируем файлы из локальной папки apache/html
COPY /var/www/html ./

# Настраиваем права
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
