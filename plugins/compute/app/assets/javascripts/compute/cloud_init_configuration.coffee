userDataFieldId = '#server_user_data'
initialRootPasswordLength = 16

@automationBootstrap=(event) ->
  event.preventDefault()
  event.stopPropagation()
  button = $(event.target)
  action = $(event.target).data('automationScriptAction')
  icon = $(event.target).find('i.fa-plus')
  icon.addClass('hide')
  spinner = $(event.target).find('i.loading-spinner-button')
  spinner.removeClass('hide')
  os_image = $('#server_image_id option:selected').data('vmwareOstype')
  osImageJSON = new Object()
  osImageJSON.vmwareOstype = os_image

  $.ajax
    url: action,
    method: 'POST'
    dataType: 'json'
    data: JSON.stringify(osImageJSON)
    success: ( data, textStatus, jqXHR ) ->
      addScriptToUserAttributes(data.script, os_image)
    error: (xhr, bleep, error) ->
      attachPopover(button, 'Error', 'Something went wrong while processing your request. Please try again later.')
    complete: () ->
      console.log("complete")
      icon.removeClass('hide')
      spinner.addClass('hide')


@initialRootPassword=(event) ->
  event.stopPropagation()
  event.preventDefault()
  userDataFieldText = $('#server_user_data').val()
  password = "\npassword: '#{randString('a-z,A-Z,0-9,#', initialRootPasswordLength)}'"
  if !userDataFieldText.trim()
    $('#server_user_data').val("#cloud-config#{password}")
  else if userDataFieldText.match("^#cloud-config")
    $('#server_user_data').val("#{$('#server_user_data').val()}#{password}")
  else
    button = $(event.target)
    attachPopover(button, 'Error', "This doesn't semm to be a valid cloud config. Cloud config files starts with #cloud-config")

@addScriptToUserAttributes = (script, os_image) ->
  button = $('a[data-toggle="automationBootstrap"]')
  if os_image == "" || os_image == null
    attachPopover(button, 'Error', "Missing property 'vmware_ostype' on the image provided. Please follow the steps described in the documentation to upload a compatible image. <a href='https://documentation.global.cloud.sap/docs/image/start/customer.html'>See customer images documentation</a>")
    return
  osTypeWindows = os_image.search("windows")
  userDataFieldText = $('#server_user_data').val()

  if !userDataFieldText.trim()
    # empty
    $('#server_user_data').val(script)
  else
    # not empty
    if osTypeWindows >= 0
      # windows
      attachPopover(button, 'Error', "Bootstrapping the automation agent on windows can’t be combined with other user data.")
    else
      # linux
      if userDataFieldText.match("^#cloud-config")
        $('#server_user_data').val("#{$('#server_user_data').val()}\n\n#{script}")
      else
        attachPopover(button, 'Error', "This doesn't semm to be a valid cloud config. Cloud config files starts with #cloud-config")

@attachPopover = (element, title, body) ->
  element.popover(
    title: title
    content: body
    html: true
  )
  element.popover('show')
  element.on 'blur', ->
    element.popover('destroy')

@randString = (set, size) ->
  dataSet = set.split(',')
  dataSize = size
  possible = ''
  if $.inArray('a-z', dataSet) >= 0
    possible += 'abcdefghijklmnopqrstuvwxyz'
  if $.inArray('A-Z', dataSet) >= 0
    possible += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  if $.inArray('0-9', dataSet) >= 0
    possible += '0123456789'
  if $.inArray('#', dataSet) >= 0
    possible += '![]{}()%&*$#^<>~@|'
  text = ''
  i = 0
  while i < dataSize
    text += possible.charAt(Math.floor(Math.random() * possible.length))
    i++
  text

$ ->
  $(document).on 'click','a[data-toggle="initialRootPassword"]', initialRootPassword
  $(document).on 'click','a[data-toggle="automationBootstrap"]', automationBootstrap