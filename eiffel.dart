import 'dart:io';

const int DEFAULT_FLOW = -1;

class Node {
  List<Node> _next = new List<Node>();
  String _ip_address;
  double _rtt;
  List<int> _flows = new List<int>();

  Node(this._ip_address, this._rtt);

  void add_child(Node n) => _next.add(n);
}

// Expects a trace file created from paris-traceroute with args '--algo=exhaustive -n'.

// TODO: support hostnames in trace
// TODO: output RTT to edges (colorize?)
void main() {
  List<String> args = new Options().arguments;

  String graph_name = "";
  Node root = null;
  List<Node> leaves = new List();

  // TODO: better arg handling.
  var in_stream = stdin;
  if (args.length == 1) {
    in_stream = new File(args[0]).openRead();
  }

  var out_stream = stdout;
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
          print("setting graph name to '$graph_name'");
          return;
        }

        if (parts[0] == "MPLS")
          return;

        if (parts.length == 3)
          return;

        print("adding hop ${parts[0]}");

        List<Node> new_leaves = new List();
        for (var i = 3; i < parts.length; i += 3) {
          String ip_flows = parts[i];
          double rtt = double.parse(parts[i+1], (source) {
            print("WARNING: bad rtt: $source.");
            return -1.0;
          });
          assert(parts[i+2] == "ms");

          List<String> ip_flows_parts = ip_flows.split(":");
          Node node = new Node(ip_flows_parts[0], rtt);
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
    .onDone(() {
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
              out_stream.writeln('    "${node._ip_address}" -> "${e._ip_address}"');
              if (!to_print.contains(e)) {
                to_print.add(e);
              }
          });
          to_print.removeAt(0);
        }
        out_stream.writeln("}");
        print("done");
    });
}
