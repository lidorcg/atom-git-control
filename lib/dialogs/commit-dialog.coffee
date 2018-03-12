git = require 'git-promise'
Dialog = require './dialog'
Core = require '../git'

module.exports =
class CommitDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon x clickable', click: 'cancel'
        @strong 'Commit'
      @div class: 'body', =>
        @label 'Commit Message'
        @textarea class: 'native-key-bindings', outlet: 'msg', keyUp: 'colorLength'
      @div class: 'buttons', =>
        @button class: 'active', click: 'commit', =>
          @i class: 'icon commit'
          @span 'Commit'
        @button click: 'cancel', =>
          @i class: 'icon x'
          @span 'Cancel'
        @input type: 'checkbox', id: 'amend', click: 'amendClick', outlet: 'amendCheckbox'
        @label 'Amend', for: 'amend'

  activate: ->
    super()
    @msg.val('')
    @msg.focus()
    return

  amendClick: ->
    cwd = Core.isInitialised()
    message_out = @msg
    amend = @amend()
    return git('log -1 --pretty=%B', {cwd: cwd})
      .then (prev_message) ->
        if (amend)
          txt = prev_message
          current_txt = message_out.val()
          if current_txt.length > 0
            if current_txt.match(/\n$/)
              txt = txt + '\n'
            txt = txt + current_txt

          message_out.val(txt)
        else
          txt = message_out.val()
          message_out.val(txt.replace(RegExp(prev_message), ''))

  amend: ->
    return @amendCheckbox.prop('checked')

  resetAmend: ->
    @amendCheckbox.prop('checked', false)

  colorLength: ->
    too_long = false
    for line, i in @msg.val().split("\n")
      if (i == 0 && line.length > 50) || (i > 0 && line.length > 80)
        too_long = true
        break

    if too_long
      @msg.addClass('over-fifty')
    else
      @msg.removeClass('over-fifty')
    return

  commit: ->
    @deactivate()
    @parentView.commit()
    return

  getMessage: ->
    return "#{@msg.val()} "
