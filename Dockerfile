FROM phppm/nginx as builder

RUN apk add php7-dev php7-pear g++ libevent-dev openssl-dev make && \
    echo -e "\n\n\n\n\n\n\n\n\n" | pecl install event

FROM phppm/nginx

COPY --from=builder /usr/lib/php7/modules/event.so /usr/lib/php7/modules/event.so
COPY --from=builder /usr/lib/libevent_extra-2.1.so.6 /usr/lib/libevent_extra-2.1.so 
COPY --from=builder /usr/lib/libevent* /usr/lib/
COPY --from=builder /lib/libssl.so.1.0.0 /lib/
COPY --from=builder /lib/libcrypto.so.1.0.0 /lib/

RUN sed -i -e 's#keepalive_timeout 65;#keepalive_timeout 65;\nkeepalive_requests 100;\nopen_file_cache max=100;#' /etc/nginx/nginx.conf
RUN sed -i -e 's#worker_processes auto;#worker_processes 4;#' /etc/nginx/nginx.conf

RUN echo 'extension=event.so' > /etc/php7/conf.d/01_event.ini
