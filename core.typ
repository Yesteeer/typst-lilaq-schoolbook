#import "@preview/lilaq:0.6.0" as lq
#import "@preview/zero:0.6.1" as zero
#import "@preview/tiptoe:0.4.0" as tiptoe
#import "@preview/elembic:1.1.1" as e

#let to-ntuple(arg, n: 2) = {
  if type(arg) != array or arg == none {
    return (arg,)*n
  }
  else {
    return arg
  }
}

#let sf-formatter(ticks, math: true, ..args) = {
  let result = lq.tick-format.linear(ticks, ..args)
  ticks.zip(result.labels).map(((tick, label)) => {
    zero.set-num(math: math)
    label
  })
}

#let diagram-axis-defaults(tick-distance: 1, subticks: 0) = {
  return (
    tick-distance: tick-distance, 
    subticks: subticks, 
  )
}

/// This function is used to plot functions with a fixed ratio between both axes. It is based on _lilaq_'s `diagram()` function, which arguments can be passed in the argument sink and will override the values computed by this package's `diagram()` function (cf. ..body).
/// 
/// *Example:*
/// 
/// ```example
/// #diagram(
///    start: -2, 
///    end: (4, 2),
///    offset: 0.5,
///    scale: 1.2,
///    tick-distance: 2,
///    subticks: 1,
///    add-to-xaxis: (exponent: 2),
///    labels: ($x$, $f(x)$),
/// )
/// ```
///
/// -> content
#let diagram(
  /// Optional coordinates of the bottom left limit of the diagram 
  /// A single number n is intepreted as the coordinates (n, n) -> float | array
  start: (0, 0),

  /// Optional coordinates of the top right limit of the diagram 
  /// A single number n is intepreted as the coordinates (n, n) -> float | array
  end: (2, 2),

  /// Optional offsets for the starting and ending coordinates.
  ///
  /// For example, with an offset of (0.2, 0.3), the diagram starts at  
  ///
  /// #align(center)[(start.x - 0.2, start.y - 0.2)] and ends at
  ///
  /// #align(center)[(end.x + 0.3, start.y + 0.3).]
  ///
  /// A single number n is interpreted as the coordinates (n, n). -> float | array
  offset: 0.3,

  /// Optional scaling along the $x$-axis (first coordinate) and the $y$-axis (second coordinate).
  ///
  /// A single number n is interpreted as the coordinates (n, n). -> float | array
  scale: 1,

  /// Changes the distance between to consecutive ticks on the axes.
  ///
  /// The first coordinate corresponds to the distance between ticks on the $x$-axis and the second one to the one on the $y$-axis. 
  /// The default: 1 corresponds to 1cm (before scaling is applied).
  ///
  /// A single number n is interpreted as the coordinates (n, n). -> int | array
  tick-distance: 1,

  /// Optional number of subticks between two ticks.
  ///
  /// The first coordinate corresponds to the distance between ticks on the $x$-axis and the second one to the one on the $y$-axis.
  /// By default, there are no subticks.
  ///
  /// A single number n is interpreted as the coordinates (n, n). -> int | array
  subticks: 0,

  /// Optional dictionary passed to the `xaxis` argument of _lilaq_' `diagram()` function (see #link("https://lilaq.org/docs/reference/diagram#xaxis")[#text(purple)[docs]])
  ///
  /// The dictionary does override the tick-distance and subticks arguments for the $x$-axis only if those are also given in the dictionary. -> none |dictionary
  add-to-xaxis: none,

  /// Optional dictionary passed to the `yaxis` argument of _lilaq_' `diagram()` function (see #link("https://lilaq.org/docs/reference/diagram#yaxis")[#text(purple)[docs]])
  ///
  /// The dictionary does override the tick-distance and subticks arguments for the $x$-axis only if those are also given in the dictionary. -> none |dictionary
  add-to-yaxis: none,

  /// Optional axes labels.
  ///
  /// The first coordinate corresponds to the $x$-axis and the second one to the $y$-axis. -> none | array
  labels: none,

  /// Positional arguments can be any of _lilaq_'s plot objects as well as this package's `plot()`.
  ///
  /// Named arguments, are passed to _lilaq_'s underlying `diagram()` function. -> any
  ..children,
) = {
  let (xlim, ylim) = to-ntuple(start).zip(to-ntuple(end))

  let (offset, scale, tick-distance, subticks) = (offset, scale, tick-distance, subticks).map(to-ntuple)

  let (width, height) = lq.vec.add(lq.vec.subtract(..(end, start).map(to-ntuple)), (offset.at(1)-offset.at(0),)*2)

  let new-add-to-xaxis = if add-to-xaxis == none {(:)} else {add-to-xaxis}
  let new-add-to-yaxis = if add-to-yaxis == none {(:)} else {add-to-yaxis}

  lq.diagram(
    width: width*scale.at(0)*1cm, 
    height: height*scale.at(1)*1cm,
    xlim: lq.vec.add(xlim, (- offset.at(0), offset.at(1))), 
    ylim: lq.vec.add(ylim, (- offset.at(0), offset.at(1))),
    xlabel: if labels != none {lq.label(
      labels.at(0, default: $x$), 
      kind: "x",
    )} else {none}, 
    ylabel: if labels != none {lq.label(
      labels.at(1, default: $y$),
      kind: "y",
    )} else {none},
    xaxis: diagram-axis-defaults(
      tick-distance: tick-distance.at(0),
      subticks: subticks.at(0),
    ) + add-to-xaxis,
    yaxis: diagram-axis-defaults(
      tick-distance: tick-distance.at(1),
      subticks: subticks.at(1),
    ) + add-to-yaxis,
    ..children
  )
}

/// This function is essentially based on _lilaq_'s `plot()` function, which arguments can be passed in the argument sink and will override the values computed by this package's `plot()` function (cf. ..args). Its main feature is that it generates a default array of x coordinates using _lilaq_'s `linspace` function. 
///
/// It needs to by passed as positional argument to a `diagram()`.
/// 
/// *Example:*
/// 
/// ```example
/// #diagram(
///   start: (0, -1.5),
///   end: (6, 1.5),
///   plot(
///      x => calc.sin(3*x), 
///      start: -1, 
///      end: 7, 
///      label: $sin(3x)$
///   ),
/// )
/// ```
///
/// -> content
#let plot(
  /// An array of $y$ coordinates (see _lilaq_ #link("https://lilaq.org/docs/reference/plot#y")[#text(purple)[docs]]). -> array | function
  y,

  /// An array of $x$ coordinates (see _lilaq_ #link("https://lilaq.org/docs/reference/plot#y")[#text(purple)[docs]]). 
  ///
  /// If set to `auto`, generates an array of $x$ coordinates with _lilaq_'s #link("https://lilaq.org/docs/reference/linspace")[#text(purple)[`linspace`]] function using the `start`, `end`, `num` and `include-end` arguments below. -> auto | array | function
  x: auto,

  /// Start of the range of the _lilaq_'s #link("https://lilaq.org/docs/reference/linspace#start")[#text(purple)[`linspace`]] function. -> int | float
  start: 0, 

  /// End of the range of the _lilaq_'s #link("https://lilaq.org/docs/reference/linspace#end`")[#text(purple)[`linspace`]] function. -> int | float
  end: 2, 

  /// Number of evenly-spaced values to produce of the _lilaq_'s #link("https://lilaq.org/docs/reference/linspace#num")[#text(purple)[`linspace`]] function. -> int
  num: 100,

  /// Whether to include the end of the range. See _lilaq_'s #link("https://lilaq.org/docs/reference/linspace#include-end")[#text(purple)[`linspace`]] function. -> bool
  include-end: true,

  /// The mark to use to mark data points. See _lilaq_'s #link("https://lilaq.org/docs/reference/plot#mark")[#text(purple)[`linspace`]] function. -> none | auto | lilaq.mark | str
  mark: none,

  /// Optional arguments to be passed to _lilaq_'s #link("https://lilaq.org/docs/reference/plot")[#text(purple)[`plot`]] function. -> any
  ..args
  
) = lq.plot(
  if x == auto {lq.linspace(start, end, num: num, include-end: include-end)} else {x},
  y,
  mark: mark,
  ..args
)

/// A theme inspired by _lilaq_'s `schoolbook` theme.
/// 
/// *Example:*
///
/// #example(`
/// #import "@preview/lilaq:0.6.0" as lq
/// #show: lilaq-schoolbook
///
/// #diagram(
///   start: (0, -2.2),
///   end: (14, 2.2),
///   add-to-xaxis: (
///     tick-distance: 1/ 2,
///     locate-ticks: lq.tick-locate.linear.with(unit: calc.pi),
///     format-ticks: lq.tick-format.fraction.with(suffix: $pi$),
///   ),
///   plot(
///      x => 2*calc.sin(x), 
///      start: -1, 
///      end: 15, 
///      label: $2sin(x)$,
///   ),
///   plot(
///      x => calc.sin(3*x), 
///      start: -1, 
///      end: 15, 
///      label: $sin(3x)$,
///      num: 200,
///   ),
/// )`, dir: ttb)
/// 
///
/// -> content
#let lilaq-schoolbook(
  body, 
  /// An option for showing the origin. -> bool
  show-origin: false
) = {

  // set some labels defaults
  show: lq.set-label(pad: none, angle: 0deg)
  show: e.show_(
    lq.label.with(kind: "x"),
    it => place(left + top, dx: 100% + .0em, dy: .4em, it)
  )
  show: e.show_(
    lq.label.with(kind: "y"),
    it => place(bottom + right, dy: -100% - .0em, dx: -.5em, it)
  )

  // set default legend styling
  show lq.selector(lq.legend): set grid(row-gutter: 5pt, columns: 2)

  // set default grid
  show: lq.set-grid(
    stroke: (paint: luma(150), dash: "dotted", thickness: .5pt),
  )

  // set default spine
  show: lq.set-spine(tip: tiptoe.tikz)

  // set some axes defaults
  let filter = {(value, distance) => if not show-origin {value != 0 and distance >= 5pt} else {distance >= 5pt}}

  let axis-args = (
    filter: filter,
    position: 0,
    scale: "linear", 
    format-ticks: sf-formatter, 
  )
  show: lq.set-diagram(xaxis: axis-args, yaxis: axis-args)

  // set ticks defaults
  show: lq.set-tick(inset: 2.0pt, outset: 2.0pt, pad: 0.4em, shorten-sub: 40%)

  // set default styling for tick label
  show lq.selector(lq.tick-label): set text(size: 10pt)

  body
}
