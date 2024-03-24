import 'dart:js_interop';
import 'dart:math';
import 'package:web/web.dart';

void main() {
  final c = document.querySelector('#output') as HTMLCanvasElement;
  c.style.width = '${window.innerWidth}px';
  c.style.height = '${window.innerHeight}px';
  c.width = window.innerWidth * 2;
  c.height = window.innerHeight * 2;
  canvas = c.getContext('2d') as CanvasRenderingContext2D;
  
  var initial = <Vertex>[];
  initial.add(Vertex(0, 0));
  initial.add(Vertex(c.width.toDouble(), 0));
  initial.add(Vertex(c.width.toDouble(), c.height.toDouble()));
  initial.add(Vertex(0, c.height.toDouble()));
  panes.add(initial);

  window.requestAnimationFrame(doFrame.toJS);
}

void doFrame(num delta) {
  draw();
  window.requestAnimationFrame(doFrame.toJS);
}

class Vertex {
  final double x;
  final double y;

  Vertex(this.x, this.y);
}

Vertex convexCombination(Vertex u, Vertex v, double d) {
  return Vertex(u.x * d + v.x * (1-d),
                u.y * d + v.y * (1-d));
}

var panes = <List<Vertex>>[];
late CanvasRenderingContext2D canvas;

void drawSegment(Vertex u, Vertex v) {
  canvas.moveTo(u.x, u.y);
  canvas.lineTo(v.x, v.y);
  canvas.stroke();
}

void draw() {
  if (panes.length > 1000) return;
  var whichPane = Random().nextInt(panes.length);
  var pane = panes[whichPane];
  var numVertices = pane.length;
  var whichVertex = Random().nextInt(numVertices);
  var whichSide = (whichVertex + (numVertices ~/ 2)
                      - (numVertices % 2 == 0 ? Random().nextInt(2) : 0))
                    % numVertices;  
      
  var cut = convexCombination(pane[whichSide],
                              pane[(whichSide+1) % numVertices],
                              Random().nextDouble());
  drawSegment(pane[whichVertex], cut);

  var pane1 = [ cut ];
  for (var i = whichVertex; i != (whichSide + 1) % numVertices; i = (i+1) % numVertices) {
    pane1.add(pane[i]);
  }

  var pane2 = [ cut ];
  for (var i = (whichSide + 1) % numVertices; i != (whichVertex + 1) % numVertices; i = (i+1) % numVertices) {
    pane2.add(pane[i]);
  }

  panes[whichPane] = pane1;
  panes.add(pane2);
}
