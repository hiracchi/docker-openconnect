# openconnect via ssh

## usage

### edit data/openconnect.conf

### boot openconnect

```
$ make start
```

```
$ make term
$ run-openconnect.sh
```

### connect via ssh

$ make copy_ssh_key
$ ssh -p 2222 -i id_rsa_docker docker@127.0.0.1
