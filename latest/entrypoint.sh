#!/bin/sh

__ldapadd() {
    ldapadd -c -Y EXTERNAL -H ldapi:/// -f /container/service/slapd/assets/ppolicy.ldif 2>&1 | \
        tee /tmp/ldapadd.log
    cat /tmp/ldapadd.log | grep -q "Can't contact LDAP server"
    if [ "$?" = "0" ]; then
        false
    fi
}

__hash_password() {
    until __ldapadd
    do
        echo trying ldapadd again in 60 seconds . . .
        sleep 60
    done
}

if [ "$LDAP_HASH_PASSWORD" = "true" ]; then
    __hash_password &
fi

exec /container/tool/run --copy-service $@
