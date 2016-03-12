class @LampTd extends React.Component
  constructor: (props) ->
    super
    @state =
      currentUser: UserStore.get()

  onChangeCurrentUser: =>
    @setState currentUser: UserStore.get()

  componentWillMount: ->
    UserStore.addChangeListener @onChangeCurrentUser

  componentWillUnmount: ->
    UserStore.removeChangeListener @onChangeCurrentUser

  render: ->
    return <td style={display: 'none'} /> unless @props.objects[@props.index]?
    <td
      width='150px'
      height='50px'
      style={
        display: @props.scores[@props.index]?.display
        backgroundColor: @props.scores[@props.index]?.color
      }
    >
      {@props.objects[@props.index].title}
      {<LampSelect display={@props.display} score={@props.scores[@props.index]} iidxid={@props.iidxid} /> if @state.currentUser.iidxid is @props.iidxid}
    </td>

LampTd.propTypes =
  objects: React.PropTypes.object.isRequired
  index: React.PropTypes.string
  scores: React.PropTypes.object.isRequired
  display: React.PropTypes.string.isRequired
  iidxid: React.PropTypes.string.isRequired
