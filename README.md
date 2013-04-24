eiffel
======

A tool that takes output from paris-traceroute and generates a dot file.

### Usage
```$ sudo paris-traceroute --algo=exhaustive XXXX | $DART_SDK/bin/dart eiffel.dart > XXXX.dot```

or
```$ sudo paris-traceroute --algo=exhaustive XXXX | $DART_SDK/bin/dart eiffel.dart -o XXXX.dot```

or
```
$ sudo paris-traceroute --algo=exhaustive XXXX > XXXX.txt
$ $DART_SDK/bin/dart eiffel.dart -i XXXX.txt -o XXXX.dot
```

or
```
$ sudo paris-traceroute --algo=exhaustive XXXX > XXXX.txt
$ $DART_SDK/bin/dart eiffel.dart -i XXXX.txt > XXXX.dot
```
