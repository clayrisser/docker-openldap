# docker-openldap

> openldap with ppolicy hashing and arbitrary slots

## Build

Run the following to build this image

```sh
make
```

## Debug

You can run the following to debug this image.

```sh
make up
```

In another terminal run the following

```sh
make ssh
```

#### Export all data

```sh
slapcat
```

#### Dump all config

```sh
slapcat -b cn=config
```

_...or_

```sh
ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config
```

#### Dump top level config

```sh
slapcat -b cn=config -a cn=config
```

_...or_

```sh
ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config cn=config
```

#### List loaded overlays

```sh
slapcat -n 0 | grep olcModuleLoad
```
