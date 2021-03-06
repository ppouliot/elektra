# import

{ div, button, span, a, i, br, tr, td} = React.DOM
{ connect } = ReactRedux
{ toggleEventDetails } = audit


Event = ({event, toggleDetails}) ->
  showDetailsClassName = if event.detailsVisible then 'fa fa-caret-down' else 'fa fa-caret-right'
  tr null,
    td null,
      a href: '#', onClick: ((e) -> e.preventDefault(); toggleDetails(event)),
        i className: showDetailsClassName, null
    td null,
      moment(event.eventTime).format("YYYY-MM-DD, HH:mm:ssZZ")
    td null,
      event.observer.typeURI
    td null,
      event.action
    td className: 'big-data-cell',
      event.target.typeURI
      br null
      span className: 'resource-id', event.target.id
    td className: 'big-data-cell',
      # in case we decide enrich the events with names in the hermes backend (not implemented)
      #if event.initiator.name && event.initiator.name.length > 0
      #  event.initiator.name
      #else
      span className: 'resource-id', event.initiator.id


Event = connect(
  (state) -> {}
  (dispatch) ->
    toggleDetails: (event) -> dispatch(toggleEventDetails(event))
)(Event)


# export
audit.EventItem = Event
