nickname = 'anonymous'
lastid = null

#Long Poll
longPoll = (data) ->
    for msg in data
        if msg.id? && msg.author? && msg.message?
            lastid = msg.id if msg.id > lastid || !lastid?
            message = "#{newTag( 'span', 'author', htmlEscape msg.author )}: #{newTag( 'span', 'messagetext', htmlEscape msg.message )}"
            $('#messages').append( newTag 'div', 'message', message )
    listenForChat()

listenForChat = () ->
    url = "/chat/#{if lastid? then lastid else 'new'}"
    $.get url, null, longPoll, 'json'

#Helpers
htmlEscape = (s) ->
    $('<div/>').text(s).html()

formFor = (f) ->
    "form[action='#{f}']"

newTag = (tag, _class, inner) ->
    "<#{tag} class=\"#{_class}\">#{inner}</#{tag}>"

#Main
$('document').ready () ->
    $('.setNickname').focus()
    $('#messages').autoscroll()
    $('#messages').ajaxError () ->
        listenForChat()
    $(formFor '/nickname/new').submit (e) ->
        e.preventDefault()
        nickname = $('.setNickname').val()
        $('#nicknamebox').fadeOut 400, () ->
            $('#chatbox').fadeIn  400, () ->
            $('.enterMessage').focus()
            listenForChat()

    $(formFor '/chat/new').submit (e) ->
        e.preventDefault()
        $.post '/chat/new', { author: nickname, message: $('.enterMessage').val() }, (data) ->
            $('.enterMessage').val ''
