# OpenLDAP Cheatsheet

## Dump

### Dump all data

```sh
slapcat
```

_...or_

```sh
slapcat -n2
```

_...or_

```sh
slapcat -b dc=example,dc=org
```

_...or_

```sh
ldapsearch -Y EXTERNAL -H ldapi:/// -b dc=example,dc=org
```

### Dump all config

```sh
slapcat -b cn=config
```

_...or_

```sh
slapcat -n0
```

_...or_

```sh
ldapsearch -Y EXTERNAL -H ldapi:/// -b cn=config
```

## Inspect

### List loaded overlays

```sh
slapcat -n0 | grep olcModuleLoad
```
