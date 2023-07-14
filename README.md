# docker-openldap

> openldap based on bitnami openldap with ppolicy, password hashing and support for ldif migrations

This image was created to address some limitations with the bitnami openldap image while still maintaining
maximum compatibility with it.

## New Features

There are several new features that have been added to this image.

### Ldif Migrations

The `/ldifs` folder does not support ldif migrations (records with a `changetype`). Instead `/ldifs` can only
add new records. If you need to modify existing records, put ldif migration files in the `/migrations` folder.

## Compatibility

This image based on the bitnami openldap image and is mostly compatible with the bitnami openldap image.

You can reference the official bitnami openldap image at the links below.

- https://bitnami.com/stack/openldap/containers
- https://github.com/bitnami/containers/blob/main/bitnami/openldap/README.md

There are a few important differences though.

1. `LDAP_CUSTOM_SCHEMA_DIR` should not be changed. If you need to add custom schemas they must be placed in the `/schemas` directory.
2. `LDAP_CUSTOM_LDIF_DIR` should not be changed. If you need to add custom ldifs they must be placed in the `/ldifs` directory.
3. The version of ldap is different than the version used in bitnami. This is because openldap had to be compiled from scratch to
   add new modules. The most stable way to compile openldap was using the src from debian. This means the version will always match
   the version of the debian release instead of the version provided by bitnami.

## Build

```sh
make build
```

## Debug

1. start openldap

   ```sh
   make up
   ```

2. open phpldapadmin at [localhost:8080](http://localhost:8080)

3. start a shell to interact with ldap

```sh
make shell
```

4. run `slapcat` or `ldapsearch` commands to test and inspect

## Info

### Schemas

The following list of schemas are included in this release of openldap and can be enabled
with the `LDAP_EXTRA_SCHEMAS` variable.

- collective
- corba
- core
- cosine
- dsee
- duaconf
- dyngroup
- inetorgperson
- java
- misc
- msuser
- namedobject
- nis
- openldap
- pmi
- ppolicy

### Modules

The following list of modules are compiled in this release of openldap.

- accesslog
- auditlog
- autogroup
- back_bdb
- back_dnssrv
- back_hdb
- back_ldap
- back_meta
- back_null
- back_passwd
- back_perl
- back_relay
- back_shell
- back_sock
- back_sql
- collect
- constraint
- dds
- deref
- dyngroup
- dynlist
- hello_world
- lastbind
- memberof
- pcache
- ppolicy
- pw-apr1
- pw-argon2
- pw-netscape
- pw-pbkdf2
- pw-sha2
- refint
- retcode
- rwm
- seqmod
- smbk5pwd
- smbkrb5pwd
- smbkrb5pwd_srv
- sssvlv
- syncprov
- translucent
- unique
- valsort
