(function() {
  var formFor, htmlEscape, lastid, listenForChat, longPoll, newTag, nickname;
  nickname = 'anonymous';
  lastid = null;
  longPoll = function(data) {
    var message, msg, _i, _len;
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      msg = data[_i];
      if ((msg.id != null) && (msg.author != null) && (msg.message != null)) {
        if (msg.id > lastid || !(lastid != null)) {
          lastid = msg.id;
        }
        message = "" + (newTag('span', 'author', htmlEscape(msg.author))) + ": " + (newTag('span', 'messagetext', htmlEscape(msg.message)));
        $('#messages').append(newTag('div', 'message', message));
      }
    }
    return listenForChat();
  };
  listenForChat = function() {
    var url;
    url = "/chat/" + (lastid != null ? lastid : 'new');
    return $.get(url, null, longPoll, 'json');
  };
  htmlEscape = function(s) {
    return $('<div/>').text(s).html();
  };
  formFor = function(f) {
    return "form[action='" + f + "']";
  };
  newTag = function(tag, _class, inner) {
    return "<" + tag + " class=\"" + _class + "\">" + inner + "</" + tag + ">";
  };
  $('document').ready(function() {
    $('.setNickname').focus();
    $('#messages').autoscroll();
    $('#messages').ajaxError(function() {
      return listenForChat();
    });
    $(formFor('/nickname/new')).submit(function(e) {
      e.preventDefault();
      nickname = $('.setNickname').val();
      return $('#nicknamebox').fadeOut(400, function() {
        $('#chatbox').fadeIn(400, function() {});
        $('.enterMessage').focus();
        return listenForChat();
      });
    });
    return $(formFor('/chat/new')).submit(function(e) {
      e.preventDefault();
      return $.post('/chat/new', {
        author: nickname,
        message: $('.enterMessage').val()
      }, function(data) {
        return $('.enterMessage').val('');
      });
    });
  });
}).call(this);
