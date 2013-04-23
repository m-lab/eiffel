// Expects a trace file created from paris-traceroute with args '--algo=exhaustive'.

import 'dart:io';

class Node {
  List<Node> _next = new List<Node>();
  String _hostname;
  String _ip_address;
  double _rtt;
  List<int> _flows = new List<int>();

  Node(this._hostname, this._ip_address, this._rtt);

  void add_child(Node n) => _next.add(n);
}

String graph_name = "";
Node root = null;
var in_stream = stdin;
var out_stream = stdout;

void writeDotFile() {
  if (root == null) {
    print("ERROR: no nodes found");
    return;
  }

  out_stream.writeln('digraph "$graph_name" {');
  List<Node> to_print = new List<Node>();
  to_print.add(root);
  while (to_print.length != 0) {
    Node node = to_print[0];
    node._next.forEach((e) {
        // TODO: simple labels instead of these
        out_stream.write('    "${node._hostname}\\n${node._ip_address}" -> "${e._hostname}\\n${e._ip_address}" ');
        out_stream.writeln('[label="${e._rtt} ms"];');
        if (!to_print.contains(e))
        to_print.add(e);
        });
    to_print.removeAt(0);
  }
  out_stream.writeln("}");
}

// TODO: color links per flow
void main() {
  List<String> args = new Options().arguments;

  List<Node> leaves = new List();

  // TODO: better arg handling.
  if (args.length == 1) {
    in_stream = new File(args[0]).openRead();
  }

  if (args.length == 2) {
    in_stream = new File(args[0]).openRead();
    out_stream = new File(args[1]).openWrite();
  }

  in_stream
    .transform(new StringDecoder())
    .transform(new LineTransformer())
    .listen((String line) {
        if (line.isEmpty)
          return;

        List<String> parts = line.trim()
            .split(new RegExp(r"\s+"))
            .where((p) => !p.startsWith("!T"))
            .toList();
        if (parts[0] == "traceroute") {
          assert(graph_name.isEmpty);
          graph_name = line;
          print("# setting graph name to '$graph_name'");
          return;
        }

        if (parts[0] == "MPLS")
          return;

        print("# adding hop ${parts[0]}");

        parts = parts.sublist(3);
        if (parts.length == 0)
          return;

        List<Node> new_leaves = new List();
        for (var i = 0; i < parts.length; i += 4) {
          String hostname = parts[i];
          String ip_flows = parts[i+1];
          double rtt = double.parse(parts[i+2], (source) {
            print("# WARNING: bad rtt: $source.");
            return -1.0;
          });
          assert(parts[i+3] == "ms");

          List<String> ip_flows_parts = ip_flows.split(":");
          Node node = new Node(hostname, ip_flows_parts[0], rtt);
          if (root == null) {
            assert(ip_flows_parts.length == 1);
            root = node;
            new_leaves.add(root);
          } else {
            if (ip_flows_parts.length == 1) {
              // No flows, so add to all leaves and collapse leaves to just the new node.
              leaves.forEach((e) => e.add_child(node));
              new_leaves.add(node);
            } else {
              // Find the leaves for the flows this ip is part of.
              node._flows = ip_flows_parts[1].split(",").map((e) => int.parse(e)).toList();

              leaves.forEach((leaf) {
                if (leaf._flows.length == 0 ||
                    leaf._flows.any((flow) => node._flows.contains(flow))) {
                  leaf.add_child(node);
                  new_leaves.add(node);
                }
              });
            }
          }
        }
        leaves = new_leaves;
    })
    .onDone(writeDotFile);
}
