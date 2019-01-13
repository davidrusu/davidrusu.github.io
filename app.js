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

    this.vx += ((width / 2) - this.x) * -0.0001;
    this.vy += ((height / 2) - this.y) * -0.0001;

    var v = max(0.01, sqrt(this.vx * this.vx + this.vy * this.vy));
    var speed = 1.;
    var ratio = 0.3;
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
  this.k = 1 * 0.5;
  
  this.update = function() {
    this.k *= random(0.9, 1.05);
    var dx = this.b.x - this.a.x;
    var dy = this.b.y - this.a.y;
    var d = max(1, sqrt(dx*dx + dy*dy));
    var f = -(this.l - d) * (1 - this.k);
    var fx = f * dx / d;
    var fy = f * dy / d;

    this.a.vx += fx;
    this.a.vy += fy;
    this.b.vx -= fx;
    this.b.vy -= fy;

    this.a.vx *= 0.9;
    this.a.vy *= 0.9;
    this.b.vx *= 0.9;
    this.b.vy *= 0.9;    
  };

  this.draw = function() {
    stroke(0);
    strokeCap(SQUARE);
    strokeWeight(max(0.1, min(10, Math.pow(this.k, 2) * 10)));
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
  for (var i = 0; i < 2000; i++) {
    points.push(new Point(random(width), random(height)));
  }
  mouseX = 0;
  mouseY = height / 2;
}

function expand_graph() {
  let close_p = undefined;
  let close_dist = undefined;
  let scd_close_p = undefined;
  let scd_close_dist = undefined;

  for (let i = 0; i < points.length; i++) {
    let p = points[i];
    let already_in_graph = false;
    for (var e of edges) {
      if (e.has_point(p)) {
	already_in_graph = true;
        break;
      }
    }
    if (already_in_graph) continue;
    
    let p_dist = dist(p.x, p.y, mouseX, mouseY);
    if (close_p == undefined || p_dist < close_dist) {
      scd_close_p = close_p;
      scd_close_dist = close_dist;
      close_p = p;
      close_dist = p_dist;
    } else if (scd_close_p == undefined || p_dist < scd_close_dist) {
      scd_close_p = p;
      scd_close_dist = p_dist;
    }
  }
  if (edges.length == 0) {
    if (scd_close_p != undefined) {
      edges.push(new Edge(close_p, scd_close_p));
    }
  } else if (close_p != undefined) {
    let close_attached_point = undefined;
    let close_attached_point_dist = undefined;
    for (var e of edges) {
      let a_dist = dist(e.a.x, e.a.y, close_p.x, close_p.y);
      let b_dist = dist(e.b.x, e.b.y, close_p.x, close_p.y);
      if (close_attached_point == undefined ||
	  a_dist < close_attached_point_dist) {
	close_attached_point = e.a;
	close_attached_point_dist = a_dist;
      }
      if (close_attached_point == undefined ||
	  b_dist < close_attached_point_dist) {
	close_attached_point = e.b;
	close_attached_point_dist = b_dist;
      }
    }
    if (close_attached_point) {
      edges.push(new Edge(close_p, close_attached_point));
    }
  }
}

function update() {
  for (var k = 0; k < 2; k++) {
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
