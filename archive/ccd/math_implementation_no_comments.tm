<TeXmacs|1.99.2>

<style|generic>

<\body>
  <doc-data|<doc-title|Collision Detection in Math>>

  <\note>
    Before we start, lets make some simplifying assumptions:

    <\enumerate-roman>
      <item>We are only dealing with circles

      <item>Circles have unit mass

      <item>Collisions are elastic

      <item>We don't handle <math|n>-body collisions
    </enumerate-roman>

    Assumptions <math|ii\<nosymbol\>.>, <math|iii.> and <math|iv.> reduce the
    collision equations to that of swapping velocities:

    <\eqnarray*>
      <tformat|<table|<row|<cell|v<rsub|a<rsub|f>>>|<cell|=>|<cell|<frac|v<rsub|a<rsub|i>><around*|(|m<rsub|a>-m<rsub|b>|)>+2m<rsub|b>v<rsub|b<rsub|i>>|m<rsub|a>+m<rsub|b>>=<frac|v<rsub|a<rsub|i>><around*|(|1-1|)>+2\<cdummy\>1\<cdummy\>v<rsub|b<rsub|i>>|1+1>=<frac|v<rsub|a<rsub|i>>\<cdummy\>0+2v<rsub|b<rsub|i>>|2>=v<rsub|b<rsub|i>>>>|<row|<cell|v<rsub|b<rsub|f>>>|<cell|=>|<cell|<frac|v<rsub|b<rsub|i>><around*|(|m<rsub|b>-m<rsub|a>|)>+2m<rsub|a>v<rsub|a<rsub|i>>|m<rsub|a>+m<rsub|b>>=<frac|v<rsub|b<rsub|i>><around*|(|1-1|)>+2\<cdummy\>1\<cdummy\>v<rsub|a<rsub|i>>|1+1>=<frac|v<rsub|b<rsub|i>>\<cdummy\>0+2v<rsub|a<rsub|i>>|2>=v<rsub|a<rsub|i>>>>>>
    </eqnarray*>
  </note>

  First we define our data model.

  \;

  <strong|Let <math|Circles=<around*|{|<around*|(|p,v,r|)>\|
  p,v\<in\>\<bbb-R\><rsup|2> and r\<in\>\<bbb-R\><rsup|+>|}>> >

  The set <strong|<math|Circles>> is all circles on the 2 dimensional plane
  with position <strong|<math|p>>, velocity <strong|<math|v>> and radius
  <strong|<math|r>>.

  \;

  We now recursively construct the sequence of worlds

  <strong|let <math|Worlds=<around*|{|world<rsub|n>|}><rsub|0><rsup|\<infty\>>>>
  where <strong|<math|world<rsub|n>\<in\>\<cal-P\><around*|(|Circles|)>><strong|>>

  <\equation>
    world<rsub|n>=<choice|<tformat|<table|<row|<cell|world<rsub|0> \<forall\>
    world<rsub|0>\<in\>\<cal-P\><around*|(|Circles|)>>|<cell|if
    n=0>>|<row|<cell|stepWorld<around*|(|world<rsub|n-1>|)>>|<cell|if
    n\<gtr\>0>>>>>
  </equation>

  \;

  <\note>
    This sequence <strong|<math|Worlds=<around*|{|world<rsub|0>,world<rsub|1>,\<ldots\>|}>>>
    can be played back by tranforming it with a render function that maps
    each world to an image ie. <strong|<math|r :
    \<cal-P\><around*|(|Circles|)>\<rightarrow\>M<rsub|640\<times\>480>>>
  </note>

  As we can see from the definition of <strong|<math|Worlds>>, every world
  <strong|<math|world<rsub|i>>> is fully dependent on the previous world
  <strong|<math|world<rsub|i-1>>> except for the very first world
  <strong|<math|world<rsub|0>>>. Thus, once the first world is chosen, all
  future worlds are determined.

  Alright, lets look at the <strong|stepWorld> function

  <strong|let <math|stepWorld:\<cal-P\><around*|(|Circles|)>\<rightarrow\>\<cal-P\><around*|(|Circles|)>>>

  <\equation>
    stepWorld<around*|(|world<rsub|n>|)>=<around*|{|c<rsub|n+1>\<in\>Circles
    \| c<rsub|n+1>=stepCircle<around*|(|circle,world<rsub|n>|)> for
    circle\<in\>world<rsub|n>|}>
  </equation>

  We will define <strong|<math|stepCirlce>> in a bit, first we need to some
  definitions.

  <\definition>
    We define the relation <strong|<math|intersect>> over <math|C>ircles

    Let <math|a,b\<in\>Circles> where <math|a=<around*|(|p<rsub|a>,v<rsub|a>,r<rsub|a>|)>>
    and <math|b=<around*|(|p<rsub|b>,v<rsub|b>,r<rsub|b>|)>>

    <\equation>
      a intersect b<space|1spc> \<Longleftrightarrow\>
      <around*|\||p<rsub|b>-p<rsub|a>|\|>\<leqslant\>r<rsub|a>+r<rsub|b>
    </equation>

    where <math|<around*|\||p<rsub|b>-p<rsub|a>|\|>> is the euclidean norm on
    <math|\<bbb-R\><rsup|2>>
  </definition>

  Now we define the function <strong|<math|colliding>> which gives us all
  circles in a world that intersect a circle

  <strong|let <math|colliding:Circles\<times\>\<cal-P\><around*|(|Circles|)>\<rightarrow\>
  \<cal-P\><around*|(|Circles|)>>>

  <\equation>
    colliding<around*|(|circle,world|)>=<around*|{|x\<in\>world \|
    x\<neq\>circle and <around*|(|circle,x|)>\<in\>intersect|}>
  </equation>

  Great, now lets define <strong|<math|stepCircle:Circles\<times\>\<cal-P\><around*|(|Circles|)>\<rightarrow\>Circle>>

  <\equation>
    stepCircle<around*|(|circle,world|)>=<choice|<tformat|<table|<row|<cell|physics<around*|(|collide<around*|(|c\<nocomma\>,world|)>|)>>|<cell|if<space|1spc>
    colliding<around*|(|c,world|)>\<neq\>\<varnothing\>
    >>|<row|<cell|physics<around*|(|c|)>>|<cell|if
    <space|1spc>colliding<around*|(|c,world|)>= \<varnothing\>>>>>>
  </equation>

  where <strong|physics> is the function that takes a circle and integrates
  the position forward one time step.

  <strong|let <math|physics:Circles\<rightarrow\>Circles>>

  <strong|let <math|\<Delta\>t=1/60>>

  <\equation>
    physics<around*|(|<around*|(|p,v,r|)>|)>=<around*|(|p+\<Delta\>t*v,v,r|)>
  </equation>

  \;

  <strong|<math|let collide:Circles\<times\>\<cal-P\><around*|(|C|)>\<rightarrow\>Circles>>

  <\equation>
    collide<around*|(|circle\<nocomma\>,world|)>=
    bounce<around*|(|circle\<nocomma\>,chooseColliding<around*|(|circle\<nocomma\>,world|)>|)>
  </equation>

  <strong|<math|let bounce:Collide\<times\>Collide\<rightarrow\>Collide>> be
  the function that updates the first circle when it collides with the second
  circle

  <\equation>
    bounce<around*|(|<around*|(|<around*|(|p<rsub|a>,v<rsub|a>,r<rsub|a>|)>,<around*|(|p<rsub|b>,v<rsub|b>,r<rsub|b>|)>|)>|)>=<around*|(|p<rsub|a>,
    v<rsub|b>,r<rsub|a>|)>
  </equation>

  Lets look at <strong|<math|chooseColliding:C\<times\>\<cal-P\><around*|(|C|)>\<rightarrow\>C>>.
  This function is a bit of a hack, its purpose is to keep the simulation
  deterministic when multiple collisions happen at the same time. The way it
  does this is it finds the `minimum' circle out of the set of circles that
  intersect with the circle we care about.

  Ok lets do it. First a definition

  <\definition>
    We define the relation <math|<around*|(|\<leqslant\>|)>> on
    <math|\<bbb-R\><rsup|2>>

    let <math|a,b,c,d\<in\>\<bbb-R\>>

    <\equation>
      <around*|(|a,b|)>\<leqslant\><around*|(|c,d|)>
      \<Longleftrightarrow\><around*|(|a\<leqslant\>c|)>\<wedge\><around*|(|b\<leqslant\>d|)>
    </equation>
  </definition>

  <strong|<math|let m:Circles\<times\>Circles\<rightarrow\>Circles>> be a
  function that chooses the minimum circle of two given circles

  <\equation>
    m<around*|(|<around*|(|<around*|(|p<rsub|a>,v<rsub|a>,r<rsub|b>|)>,<around*|(|p<rsub|b>,v<rsub|b>,r<rsub|b>|)>|)>|)>=<choice|<tformat|<table|<row|<cell|<around*|(|p<rsub|a>,v<rsub|a>,r<rsub|a>|)>>|<cell|if
    <around*|(|p<rsub|a>\<leqslant\>p<rsub|b>|)>\<wedge\><around*|(|v<rsub|a>\<leqslant\>v<rsub|b>|)>\<wedge\><around*|(|r<rsub|a>\<leqslant\>r<rsub|b>|)>>>|<row|<cell|<around*|(|p<rsub|b>,v<rsub|b>,r<rsub|b>|)>>|<cell|if
    \<neg\><around*|(|<around*|(|p<rsub|a>\<leqslant\>p<rsub|b>|)>\<wedge\><around*|(|v<rsub|a>\<leqslant\>v<rsub|b>|)>\<wedge\><around*|(|r<rsub|a>\<leqslant\>r<rsub|b>|)>|)>>>>>>
  </equation>

  <\equation>
    chooseColliding<around*|(|c,w|)>=x for
    x\<nosymbol\>\<in\>colliding<around*|(|c,w|)>
    <space|1spc>s.t\<nosymbol\>. \<forall\>a\<in\>colliding<around*|(|c,w|)>,m<around*|(|x,a|)>=x
  </equation>

  <\theorem>
    <math|\<forall\>c\<in\>Circles,\<forall\>w\<in\>\<cal-P\><around*|(|Circles|)>>,
    <math|\<exists\>!x\<in\>Circles s.t\<nosymbol\>.
    x=chooseColliding<around*|(|c,w|)>>

    not going to prove this here, cause i don't want to have to prove it for
    the python version. But just have to show that
    <math|<around*|(|p<rsub|a>\<leqslant\>p<rsub|b>|)>\<wedge\><around*|(|v<rsub|a>\<leqslant\>v<rsub|b>|)>\<wedge\><around*|(|r<rsub|a>\<leqslant\>r<rsub|b>|)>>
    defines a total ordering on Circles.
  </theorem>
</body>