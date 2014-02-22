Parallel Cooridnates
=========================

A toolkit to add multiple charts feature onto parallel coordinates implementation in D3 <http://mbostock.github.io/d3/talk/20111116/iris-parallel.html>. Reimplement it in Coffee script.

Usage
======
window.paral_cord (option);

avaialble option:

* marginLeft (opt): Left margin, default is 100
* marginRight (opt): Right margin, default is 100
* marginTop (opt): Top margin, default is 50
* marginBottom (opt): Buttom margin, default is 50
* width (opt): Width of the whole SVG graph, default is 800
* height (opt): Height of the whole SVG graph, default is 400
* spacer (opt): Space between two chargs, default is 30
* titleSize (opt): The font size of titles of each charts, default is 20
* colorDecider (opt): A function accepting a data entry and return a color string. Default is "blue"
* rootDom (required): The root dom selector to render SVN graph
* data (required): Array of data entry:
  * path (required): The url to fetch data set
  * name (required): The title of data set
  * format (required): The format of data set
* units (required): Mapping from attribute name to its data entry property
  * name (required): Title of the attribute, will be used as the axis name
  * type (required): "number" or "text"
  * domain (opt): An array represented domain, used when ordinal domain needs certain order

Dependency
==============

* jQuery
* d3js
* underscore

License
==============
Just steal the shit of it.

TODO
==============

1. Support multiple data format
2. Support asynchronous data loading
3. Demo page
