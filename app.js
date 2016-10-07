var air = 1;

function dotted_line(x1, y1, x2, y2) {
  var dx = x2 - x1;
  var dy = y2 - y1;
  var d = max(1, sqrt(dx * dx + dy * dy));
  var step_size = 15;
  var x_step = dx / d * step_size;
  var y_step = dy / d * step_size;
  var steps = Math.floor(d / step_size);
  for (var i = 0; i < steps; i++) {
    var x = x1 + x_step * i;
    var y = y1 + y_step * i;
    point(x, y);
  }
}

function Point(x, y) {
  this.x = x;
  this.y = y;
  this.vx = random(-1, 1);
  this.vy = random(-1, 1);

  this.update = function() {
    this.vx *= air;
    this.vy *= air;
    var padding = 100;
    var wall_k = 0.01;
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

    var v = max(0.001, sqrt(this.vx * this.vx + this.vy * this.vy));
    var speed = 1;
    this.vx = this.vx / v * speed;
    this.vy = this.vy / v * speed;
    this.x += this.vx;
    this.y += this.vy;
  };
  
  this.draw = function() {
    //stroke(0);
    //strokeWeight(1);
    //point(this.x, this.y);
  };

  this.dist = function(other) {
    var dx = this.x - other.x;
    var dy = this.y - other.y;
    return sqrt(dx*dx + dy*dy);
  };
}

function Edge(a, b) {
  this.a = a;
  this.b = b;
  var dx = b.x - a.x;
  var dy = b.y - a.y;
  this.l = sqrt(dx * dx + dy * dy) * 0.1;
  this.k = 1;
  
  this.update = function() {
    this.k *= 0.9;
    var dx = this.b.x - this.a.x;
    var dy = this.b.y - this.a.y;
    var d = max(1, sqrt(dx*dx + dy*dy));
    var nx = dx / d;
    var ny = dy / d;
    var f = -(this.l - d) * this.k;

    this.a.vx += f*nx;
    this.a.vy += f*ny;
    this.b.vx -= f*nx;
    this.b.vy -= f*ny;
  };

  this.draw = function() {
    stroke(150);
    strokeWeight(max(0.5, min(1.5, this.k * 100)));
    line(this.b.x, this.b.y, this.a.x, this.a.y);
    //stroke(0);
    //strokeWeight(max(1, min(2, this.k * 100)));
    //strokeWeight(2);
    //dotted_line(this.b.x, this.b.y, this.a.x, this.a.y);
    
    
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

function update() {
  for (var k = 0; k < 1; k++) {
  if (random() < 0.99) {
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
  }
  
  for (var i = 0; i < points.length; i++) {
    var p1 = points[i];
    for (var j = i + 1; j < points.length; j++) {
      var p2 = points[j];
      var dx = p2.x - p1.x;
      var dy = p2.y - p1.y;
      var d = max(100, sqrt(dx*dx + dy*dy));
      var nx = dx / d;
      var ny = dy / d;
      var f = -1 / (d * d) * 100;
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
//
//
//$(function() {
//  console.log('on load');
//
//  console.log(p5);
//});
//
//var AIR = 0.9;
//var points = [];
//
//function Point(x, y, vx, vy) {
//  this.x = x;
//  this.y = y;
//  this.vx = vx;
//  this.vy = vy;
//
//  this.update = function() {
//    this.x += this.vx;
//    this.y += this.vy;
//    this.vx *= AIR;
//    this.vy *= AIR;
//  };
//
//  this.draw = function() {
//    ellipse(this.x, this.y, 1, 1);
//  };
//}
//
//function setup() {
//  var cnv = createCanvas(windowWidth, windowHeight);
//  cnv.parent('bg_sketch');
//  for (var i = 0; i < 100; i++) {
//    points.push(new Point(random(width), random(height), 0, 0));
//  }
//}
//
//function update() {
//  points.forEach(function(p) {
//    p.update();
//  });
//  
//  for (var i = 0; i < points.length; i++) {
//    var p1 = points[i];
//    for (var j = i + 1; j < points.length; j++) {
//      var p2 = points[j];
//      var dx = p2.x - p1.x;
//      var dy = p2.y - p1.y;
//      var d = max(1, sqrt(dx * dx + dy * dy));
//      var nx = dx / d;
//      var ny = dy / d;
//      var k = 0.01;
//      var f;
//      if (abs(j - i) < 3) {
//	f = (d - 50) * k;
//      } else {
//	f = (d - 500) * k * 0.001;
//      }
//      p1.vx += nx * f;
//      p1.vy += ny * f;
//      p2.vx -= nx * f;
//      p2.vy -= ny * f;
//    }
//  }
//
//  for (var i = 0; i < points.length; i++) {
//    var p = points[i];
//    var w = 0.00001;
//    p.vx += (width / 2 - p.x) * w;
//    p.vy += (height / 2 - p.y) * w;
//  }
//
//  for (var i = 0; i < points.length; i++) {
//    var p = points[i];
//    var w = 50;
//    var dx = mouseX - p.x;
//    var dy = mouseY - p.y;
//    var d = max(1, sqrt(dx * dx + dy * dy));
//    var nx = dx / d;
//    var ny = dy / d;
//    var f = -1 / (d) * w;
//    //p.vx += nx * f;
//    //p.vy += ny * f;
//  }
//
//  for (var i = 0; i < points.length; i++) {
//    var p = points[i];
//    var w = 0.001;
//    var cellWidth = 50;
//    var cellHeight = 50;
//    //p.vx += (Math.floor((p.x + cellWidth / 2) / cellWidth) * cellWidth - p.x) * w;
//    //p.vy += (Math.floor((p.y + cellHeight / 2) / cellHeight) * cellHeight - p.y) * w;
//  }
//}
//
//function draw() {
//  background(255);
//  update();
//
//  for (var i = 0; i < points.length * 2; i += 1) {
//    var p1 = points[i % points.length];
//    var p2 = points[(i + 1) % points.length];
//    var p3 = points[(i + 2) % points.length];
////    for (var j = i+1; j < points.length; j++) {
//    var t = (sin(millis() / 1000.0) + 1) / 2;
//    //stroke(t * 255);
//    stroke(0);
//    strokeWeight(0.1);
//    noFill();
//    bezier(p1.x + (p2.x - p1.x) * 0.5,
//	   p1.y + (p2.y - p1.y) * 0.5,
//	   p2.x, p2.y,
//	   p2.x, p2.y,
//	   p3.x + (p2.x - p3.x) * 0.5,
//	   p3.y + (p2.y - p3.y) * 0.5);
//    
////    stroke(255, 0, 0);
//    
//    //line(p1.x, p1.y, p2.x, p2.y);
//  //  }
//  }
//}
//
