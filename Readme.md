Для установки требуется выполнить:

1. Скопировать файлы cp -r luasrc/controller/* /usr/lib/lua/luci/controller
2. Скопировать файлы cp -r luasrc/model/* /usr/lib/lua/luci/model
3. Скопировать файлы cp -r luasrc/view/* /usr/lib/lua/luci/view
4. Скопировать файлы cp -r luci-static/resources/* /www/luci-static/resources
5. Очистить кеш rm -r /tmp/luci*
6. Перезапустить сервер /etc/init.d/uhttpd restart
