eiffel
======

A tool that takes output from paris-traceroute and generates a dot file.

[![Build Status](https://drone.io/github.com/m-lab/eiffel/status.png)](https://drone.io/github.com/m-lab/eiffel/latest)

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
