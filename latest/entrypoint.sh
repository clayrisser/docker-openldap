#!/bin/sh

__ldapadd() {
    ldapadd -c -Y EXTERNAL -H ldapi:/// -f /container/service/slapd/assets/ppolicy.ldif 2>&1 | \
        tee /tmp/ldapadd.log
    cat /tmp/ldapadd.log | grep -q "Can't contact LDAP server"
    if [ "$?" = "0" ]; then
        false
    fi
}

__init() {
    until __ldapadd
    do
        echo trying ldapadd again in 60 seconds . . .
        sleep 60
    done
}

__init &

if [ "$LDAP_DEBUG" = "true" ]; then
    exec /container/tool/run -l debug --copy-service $@
else
    exec /container/tool/run -l info --copy-service $@
fi
