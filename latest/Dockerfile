FROM osixia/openldap:1.5.0

ADD ppolicy.ldif /container/service/slapd/assets
ADD bootstrap /container/service/slapd/assets/config/bootstrap
ADD entrypoint.sh /usr/local/sbin/entrypoint

RUN chmod +x /usr/local/sbin/entrypoint

ENTRYPOINT [ "/bin/sh", "/usr/local/sbin/entrypoint" ]
