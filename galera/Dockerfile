from mariadb

env TZ=Asia/Shanghai

run mkdir -p /data /log \
    && chown -R mysql.mysql /data /log

copy mariadb.cnf my.cnf /etc/mysql/
