eiffel
======

A tool that takes output from paris-traceroute and generates a dot file.

### Usage
```$ sudo paris-traceroute --algo=exhaustive -n XXXX | $DART_SDK/bin/dart eiffel.dart > XXXX.dot```

or
```
$ sudo paris-traceroute --algo=exhaustive -n XXXX > XXXX.txt
$ $DART_SDK/bin/dart eiffel.dart XXXX.txt XXXX.dot
```
