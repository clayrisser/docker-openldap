# docker-openldap

> openldap based on bitnami openldap with ppolicy, password hashing and support for ldif migrations

```sh
docker pull registry.gitlab.com/bitspur/rock8s/docker-openldap
```

This image was created to address some limitations with the bitnami openldap image while still maintaining
maximum compatibility with it.

You can view additional versions of the image at https://gitlab.com/bitspur/rock8s/docker-openldap/container_registry/4388893.

## New Features

There are several new features that have been added to this image.

#### 1. Password hashing

A new environment variable called `LDAP_HASH_PASSWORD` has been added that will automatically setup
the environment to hash passwords. By default it is set to `SHA512CRYPT`, the strongest hashing
algorithm available. The available options are the following.

- `NONE`
- `SSHA`
- `MD5`
- `CRYPT`
- `MD5CRYPT`
- `SHA256CRYPT`
- `SHA512CRYPT`

#### 2. Ldif migrations

The `/ldifs` folder does not support ldif migrations (records with a `changetype`). Instead `/ldifs` can only
add new records.

If you need to modify existing records, put ldif migration files in the `/migrations` folder.

#### 3. Support for .schema extension

The `/schemas` directory can include `.ldif` schemas or `.schema` schemas.

You can see some examples at [context/schemas](context/schemas).

#### 4. Templating support

The `/schemas`, `/ldifs` and `/migrations` directories all support `.ldif.tmpl` files which will be templated.

You can see an example at [context/ldifs/00-organization.ldif.tmpl](context/ldifs/00-organization.ldif.tmpl).

#### 5. Support for additional modules and schemas

You can find the list of supported modules and schemas [HERE](#supported-modules-and-schemas)

#### 6. Easily compile custom modules into the image

You can see an example of this in the [Dockerfile](Dockerfile#L49)

## Compatibility

his image based on the bitnami openldap image and is mostly compatible with the bitnami openldap image.

You can reference the official bitnami openldap image at the links below.

- https://bitnami.com/stack/openldap/containers
- https://github.com/bitnami/containers/blob/main/bitnami/openldap/README.md

There are a few important differences though.

1.  `LDAP_CUSTOM_SCHEMA_DIR` should not be changed. If you need to add custom schemas they must be placed in the `/schemas` directory.
2.  `LDAP_CUSTOM_LDIF_DIR` should not be changed. If you need to add custom ldifs they must be placed in the `/ldifs` directory.
3.  The version of ldap is different than the version used in bitnami. This is because openldap had to be compiled from scratch to
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

## Supported Modules and Schemas

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
