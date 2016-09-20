$(function() {
  console.log('on load');

  console.log(p5);
});

var AIR = 0.9;
var points = [];

function Point(x, y, vx, vy) {
  this.x = x;
  this.y = y;
  this.vx = vx;
  this.vy = vy;

  this.update = function() {
    this.x += this.vx;
    this.y += this.vy;
    this.vx *= AIR;
    this.vy *= AIR;
  };

  this.draw = function() {
    ellipse(this.x, this.y, 1, 1);
  };
}

function setup() {
  var cnv = createCanvas(windowWidth, windowHeight);
  cnv.parent('bg_sketch');
  for (var i = 0; i < 100; i++) {
    points.push(new Point(random(width), random(height), 0, 0));
  }
}

function update() {
  points.forEach(function(p) {
    p.update();
  });
  
  for (var i = 0; i < points.length; i++) {
    var p1 = points[i];
    for (var j = i + 1; j < points.length; j++) {
      var p2 = points[j];
      var dx = p2.x - p1.x;
      var dy = p2.y - p1.y;
      var d = max(1, sqrt(dx * dx + dy * dy));
      var nx = dx / d;
      var ny = dy / d;
      var k = 0.01;
      var f;
      if (abs(i - j) < 3) {
	f = (d - 500) * k;
      } else {
	f = -1 / (d * d) * k * 100;
      }
      p1.vx += nx * f;
      p1.vy += ny * f;
      p2.vx -= nx * f;
      p2.vy -= ny * f;
    }
  }

  for (var i = 0; i < points.length; i++) {
    var p = points[i];
    var w = 0.000001;
    p.vx += (width / 2 - p.x) * w;
    p.vy += (height / 2 - p.y) * w;
  }

  for (var i = 0; i < points.length; i++) {
    var p = points[i];
    var w = 0.001;
    var cellWidth = 50;
    var cellHeight = 50;
    //p.vx += (Math.floor((p.x + cellWidth / 2) / cellWidth) * cellWidth - p.x) * w;
    //p.vy += (Math.floor((p.y + cellHeight / 2) / cellHeight) * cellHeight - p.y) * w;
  }
}

function draw() {
  background(255);
  update();

  for (var i = 0; i < points.length * 2; i += 1) {
    var p1 = points[i % points.length];
    var p2 = points[(i + 1) % points.length];
    var p3 = points[(i + 2) % points.length];
//    for (var j = i+1; j < points.length; j++) {
    var t = (sin(millis() / 1000.0) + 1) / 2;
    //stroke(t * 255);
    stroke(0);
    strokeWeight(0.1);
    noFill();
    bezier(p1.x + (p2.x - p1.x) * 0.5,
	   p1.y + (p2.y - p1.y) * 0.5,
	   p2.x, p2.y,
	   p2.x, p2.y,
	   p3.x + (p2.x - p3.x) * 0.5,
	   p3.y + (p2.y - p3.y) * 0.5);
    
//    stroke(255, 0, 0);
    
    //line(p1.x, p1.y, p2.x, p2.y);
  //  }
  }
}
