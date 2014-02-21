paral_cord = (option) ->
    
    deft =
        marginLeft: 100
        marginRight: 100
        marginTop: 50
        marginBottom: 50
        width: 800
        height: 400
        spacer: 30
        titleSize: 20
        colorDecider: (d) -> "blue"

    # Prepare utilities
    
    option = $.extend {}, deft, option
    num_charts = option.data.length
    chartHeight = (option.height - (num_charts - 1) * option.spacer) / num_charts
    props = d3.keys option.units
    line = d3.svg.line()
    axis = d3.svg.axis().orient "left"

    x = d3.scale
        .ordinal()
        .domain props
        .rangePoints [0, option.width]

    y = {}

    data = []

    boundary = {}
        
    # Synchronized Load Data
    formatData = (d) ->
        props.forEach (p) ->
            if option.units[p].type == "number" then d[p] = +d[p]
            
    loadData = (callback) ->
        # Only do tsv right now
        fs = [callback]
        option.data.forEach (d, ind) ->
            fs.push () ->
                d3.tsv d.path, (err, d) -> d.forEach formatData; data.push d; fs[ind](); return
                return
            return
        fs[option.data.length]()
        return

    # Process scaling
    combineText = (p) ->
        aux = data.map (d) -> d.map (t) -> t[p]
        aux = _.flatten aux
        ret = []
        aux.forEach (d) -> ret = _.union ret, d; return
        ret
    
    processScale = () ->
        props.forEach (p) ->
            helper = data.map (d) -> d3.extent d, (x) -> x[p]
            boundary[p] = helper[0]
            helper.forEach (bound) ->
                boundary[p][0] = Math.min boundary[p][0], bound[0]
                boundary[p][1] = Math.max boundary[p][1], bound[1]    
            if (option.units[p].type == "number")
                y[p] = d3.scale.linear()
                         .domain boundary[p]
                         .range [chartHeight, 0]
            else
                if (option.units[p].domain)
                    y[p] = d3.scale.ordinal()
                             .domain option.units[p].domain
                             .rangePoints [chartHeight, 0]
                else
                    y[p] = d3.scale.ordinal()
                             .domain (combineText p)
                             .rangePoints [chartHeight, 0]
            y[p].brush = d3.svg.brush().y(y[p]).on("brush", brush);
        return

    # Build Component

    svg = d3.select option.rootDom
            .append "svg"
            .attr "width", option.width + option.marginLeft + option.marginRight
            .attr "height", option.height + option.marginTop + option.marginBottom
            .append "g"
            .attr "transform", "translate(#{option.marginLeft}, #{option.marginTop})"

    buildG = (n) ->
        ret = svg.append "g"
                 .attr "class", "chart"
                 .attr "width", option.width
                 .attr "height", chartHeight
                 .attr "transform", "translate(0, #{n * (option.spacer + chartHeight)})"
        ret.append "text"
           .attr "x", option.width / 2
           .attr "y", - option.spacer / 2
           .attr "text-anchor", "middle"
           .style "font-size", option.titleSize
           .style "text-decoration", "underline"
           .text "#{option.data[n].name}"
        ret

    charts = (buildG i for i in [0..num_charts-1])

    # Draw Axis and Label here
    drawAxis = (g) ->
        trait = g.selectAll ".trait"
                 .data props
                 .enter()
                 .append "g"
                 .attr "class", "trait"
                 .attr "transform", (p) -> "translate(#{x p})"
                 .call( d3.behavior.drag()
                     .origin (p) -> {x: x p}
                     .on "dragstart", axisDragStart
                     .on "drag", axisDrag
                     .on "dragend", axisDragEnd)
                 
        trait.append "g"
             .attr "class", "axis"
             .each (d) -> d3.select(this).call axis.scale(y[d])
             .append "text"
             .attr "text-anchor", "middle"
             .attr "y", -9
             .text (d) -> option.units[d].name

        trait.append "g"
             .attr "class", "brush"
             .attr "axis-label", String
             .each (d) -> d3.select(@).call(y[d].brush)
             .selectAll "rect"
             .attr "x", -8
             .attr "width", 16
        g.trait = trait
        
        return

    # Axis Dragging
    axisDragStart = (p) -> i = props.indexOf p
    axisDrag = (p) ->
        x.range()[i] = d3.event.x
        props.sort (a, b) -> (x a) - (x b)
        charts.forEach (chart) -> chart.trait.attr "transform", (p) -> "translate(#{x p})"
        charts.forEach (chart) -> chart.foreground.attr "d", path
        
    axisDragEnd = (p) ->
        x.domain props
         .rangePoints [0, option.width]
        t = d3.transition().duration 500
        t.selectAll ".trait"
         .attr "transform", (d) -> "translate(#{x d})"
        t.selectAll ".foreground path"
         .attr "d", path
        return
    # Draw Lines

    path = (d) -> line props.map (p) -> [x(p), y[p](d[p])]

    drawLines = (g, data) ->
        foreground =
            g.append "g"
             .attr "class", "foreground"
             .selectAll "path"
             .data data
             .enter()
             .append "path"
             .attr "d", path
             .attr "stroke", option.colorDecider
        g.foreground = foreground
        return
    
    # Brushing
    brush = () ->
        actives = props.filter (p) -> not y[p].brush.empty()
        extents = actives.map (p) -> y[p].brush.extent()
        charts.forEach (c) ->
            props.forEach (p) -> c.select("[axis-label=\"#{p}\"]").call(
                if actives.indexOf(p) >= 0 then y[p].brush.extent extents[actives.indexOf p]
                else y[p].brush.clear())
            c.foreground.classed "fade", (d) ->
                !actives.every (p, i) ->
                    if (option.units[p].type == "number")
                        extents[i][0] <= d[p] && d[p] <= extents[i][1]
                    else
                        extents[i][0] <= y[p](d[p]) && y[p](d[p]) <= extents[i][1]
        return
        
    # Whole Logic
    loadData () ->
        processScale()
        charts.forEach drawAxis
        (drawLines charts[i], data[i] for i in [0..num_charts-1])
        return

window.paral_cord = paral_cord
