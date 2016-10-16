var air = 1;

function Point(x, y) {
  this.x = x;
  this.y = y;
  this.vx = random(-1, 1);
  this.vy = random(-1, 1);

  this.update = function() {
    var padding = 70;
    var wall_k = 0.1;
    if (this.x < padding) {
      this.vx += (padding - this.x) * wall_k;
    } else if (this.x > (width - padding)) {
      this.vx += ((width - padding) - this.x) * wall_k;
    }
    if (this.y < padding) {
      this.vy += (padding - this.y) * wall_k;
    } else if (this.y > (height - padding)) {
      this.vy += ((height - padding) - this.y) * wall_k;
    }

    this.vx += ((width / 2) - this.x) * -0.00001;
    this.vy += ((height / 2) - this.y) * -0.00001;

    var v = max(0.001, sqrt(this.vx * this.vx + this.vy * this.vy));
    var speed = 0.5;
    var ratio = 0.2;
    this.vx = this.vx * ratio + (this.vx / v * speed * (1 - ratio));
    this.vy = this.vy * ratio + (this.vy / v * speed * (1 - ratio));
    this.x += this.vx;
    this.y += this.vy;
  };
  
  this.draw = function() {};

  this.dist = function(other) {
    var dx = this.x - other.x;
    var dy = this.y - other.y;
    return sqrt(dx*dx + dy*dy);
  };
}

function Edge(a, b) {
  this.a = a;
  this.b = b;
  this.l = a.dist(b) * 0.1;
  this.k = 1;
  
  this.update = function() {
    this.k *= 0.9;
    var dx = this.b.x - this.a.x;
    var dy = this.b.y - this.a.y;
    var d = max(1, sqrt(dx*dx + dy*dy));
    var f = -(this.l - d) * this.k;
    var fx = f * dx / d;
    var fy = f * dy / d;

    this.a.vx += fx;
    this.a.vy += fy;
    this.b.vx -= fx;
    this.b.vy -= fy;
  };

  this.draw = function() {
    stroke(200);
    strokeWeight(max(0.5, min(1, this.k * 100)));
    line(this.b.x, this.b.y, this.a.x, this.a.y);
  };

  this.is_dead = function() {
    return this.k < 0.001;
  };

  this.has_point = function(p) {
    return this.a === p || this.b == p;
  };
}

var points = [];
var edges = [];

function setup() {
  var cnv = createCanvas(windowWidth, windowHeight);
  cnv.parent('bg_sketch');
  for (var i = 0; i < 300; i++) {
    points.push(new Point(random(width), random(height)));
  }
}

function expand_graph() {
  points.sort(function(a, b) {
    return dist(a.x, a.y, mouseX, mouseY) - dist(b.x, b.y, mouseX, mouseY);
  });
  var valid = points.filter(function(p) {
    for (var e of edges) {
      if (e.has_point(p)) {
	return false;
      }
    }
    return true;
  });
  if (edges.length == 0) {
    if (valid.length > 2) {
      edges.push(new Edge(valid[0], valid[1]));
    }
  } else if (valid.length >= 1) {
    var p = valid[0];
    points.sort(function(a, b) {
      return dist(a.x, a.y, p.x, p.y) - dist(b.x, b.y, p.x, p.y);
    });
    var attachablePoints = points.filter(function(p) {
      for (var e of edges) {
	if (e.has_point(p)) {
	  return true;
	}
      }
      return false;
    });
    edges.push(new Edge(p, attachablePoints[0]));
  }
}

function update() {
  for (var k = 0; k < 1; k++) {
    expand_graph();
  }
  
  for (var i = 0; i < points.length; i++) {
    var p1 = points[i];
    for (var j = i + 1; j < points.length; j++) {
      var p2 = points[j];
      var dx = p2.x - p1.x;
      var dy = p2.y - p1.y;
      var d = dx*dx + dy*dy;
      if (d > 30*30) {
	continue;
      }
      d = max(50, sqrt(d));
      var nx = dx / d;
      var ny = dy / d;
      var f = -1 / (d * d) * 1000;
      p1.vx += f*nx;
      p1.vy += f*ny;
      p2.vx -= f*nx;
      p2.vy -= f*ny;
    }
  }

  var edges_to_remove = [];
  edges.forEach(function(e) {
    e.update();
    if (e.is_dead()) {
      edges_to_remove.push(e);
    }
  });

  edges_to_remove.forEach(function(e) {
    edges.splice(edges.indexOf(e), 1);
  });

  points.forEach(function(p) {
    p.update();
  });
}

function draw() {
  update();
  background(255);
  points.forEach(function(p) {
    p.draw();
  });
  
  edges.forEach(function(e) {
    e.draw();
  });
}
