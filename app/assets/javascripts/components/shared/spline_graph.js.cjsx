class @SplineGraph extends React.Component
  constructor: (props) ->
    super
    today = new Date()
    @state =
      year: today.getFullYear()
      month: today.getMonth() + 1
      options:
        chart:
          renderTo: 'spline-graph'
          defaultSeriesType: 'spline'
        title:
          text: '統計情報'
        xAxis:
          categories: ['2015-12', '2016-01', '2016-02']
        yAxis: [
          {
            allowDecimals: false
            title:
              text: '更新数'
            max: 40
            opposite: true
          },
          {
            allowDecimals: false
            title:
              text: '未達成数'
          }
        ]
        tooltip:
          shared: true
          crosshairs: true
        series: [
          { yAxis: 0, type: 'column', name: 'FC', data: [15, 10, 20], color: '#ff8c00' }
          { yAxis: 0, type: 'column', name: 'EXH', data: [30, 20, 22], color: '#ffd900' }
          { yAxis: 0, type: 'column', name: 'HARD', data: [40, 10, 33], color: '#ff6347' }
          { yAxis: 0, type: 'column', name: 'CLEAR', data: [5, 2, 1], color: '#afeeee' }
          { yAxis: 0, type: 'column', name: 'EASY', data: [3, 0, 0], color: '#98fb98' }
          { yAxis: 1, type: 'spline', name: '未FC', data: [70, 60, 40], color: '#ff8c00' },
          { yAxis: 1, type: 'spline', name: '未EXH', data: [60, 40, 18], color: '#ffd900' },
          { yAxis: 1, type: 'spline', name: '未難', data: [80, 70, 47], color: '#ff6347' },
          { yAxis: 1, type: 'spline', name: '未クリア', data: [20, 12, 11], color: '#afeeee' },
          {
            type: 'pie'
            name: 'クリア割合'
            data: [
              { name: 'FC', y: 10, color: '#ff8c00' },
              { name: 'EXH', y: 10, color: '#ffd900' },
              { name: 'HARD', y: 10, color: '#ff6347' },
              { name: 'CLEAR', y: 10, color: '#afeeee' },
              { name: 'EASY', y: 10, color: '#98fb98' }
              { name: 'ASSIST', y: 10, color: '#9595ff' }
              { name: 'FAILED', y: 10, color: '#c0c0c0' }
              { name: 'NOPLAY', y: 10, color: '#ffffff' }
            ]
            center: [300, 60]
            size: 100
            showInLegend: false
            dataLabels:
                enabled: false
          }
        ]

  onChangePie: (options, graph) ->
    for _, index in options.series[9].data
      options.series[9].data[index].y = graph.pie[index]
    options.series[9].center = [50, 40]

  onChangeColumn: (options, graph) ->
    for index in [0..4]
      options.series[index].data = graph.column[index]
    options.yAxis[0].max = graph.column_max

  onChangeSpline: (options, graph) ->
    for index in [5..8]
      options.series[index].data = graph.spline[index - 5]
    options.yAxis[1].max = graph.spline_max

  onChangeGraph: =>
    graph = GraphStore.get()
    options = @state.options
    options.xAxis.categories = graph.categories
    @onChangePie options, graph
    @onChangeColumn options, graph
    @onChangeSpline options, graph
    @setState options: options, @renderChart

  componentWillMount: ->
    GraphStore.addChangeListener @onChangeGraph
    today = new Date()
    @getGraph() unless @props.initialRender

  getGraph: ->
    GraphActionCreators.get iidxid: @props.iidxid, year: @state.year, month: @state.month

  componentWillUnmount: ->
    GraphStore.removeChangeListener @onChangeGraph

  componentDidMount: ->
    @renderChart() if @props.initialRender

  renderChart: =>
    new Highcharts.Chart @state.options

  onClickPrev: =>
    year = @state.year
    month = @state.month
    if @state.month is 1
      year--
      month = 12
    else
      month--
    @setState year: year, month: month, @getGraph

  onClickNext: =>
    year = @state.year
    month = @state.month
    if @state.month is 12
      year++
      month = 1
    else
      month++
    @setState year: year, month: month, @getGraph

  render: ->
    <div>
      <div id='spline-graph' />
      {<button className='uk-button uk-button-danger' onClick={@onClickPrev}>prev</button> unless @props.initialRender}
      {<button className='uk-button uk-button-primary' onClick={@onClickNext}>next</button> unless @props.initialRender}
    </div>

SplineGraph.propTypes =
  initialRender: React.PropTypes.bool.isRequired
  iidxid: React.PropTypes.string
