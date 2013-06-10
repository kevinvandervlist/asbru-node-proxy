# Copyright (c) 2013, Kevin van der Vlist
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#= require NodeMessage.coffee

class CommManager
  constructor: ->
    @_outIO = null
    @_outNode = null
    @buffer = ""

  inIO: (data) =>
    @outNode data

  outIO: (data) =>
    @_outIO data if @_outIO?

  setOutIO: (fn) ->
    @_outIO = fn

  inNode: (data) =>
    @buffer += data
    @flush()

  outNode: (data) =>
    @_outNode data if @_outNode?

  setOutNode: (fn) ->
    @_outNode = fn

  flush: =>
    # Parse the message first
    message = new NodeMessage @buffer
    # If the buffer is a complete message, pass it on and remove it from the buffer.
    if message.isComplete()
      @buffer = @buffer.substring(message.getSize())
      @outIO message.getBody()
      # If the buffer still contains data; flush again.
      @flush() if @buffer.length > 0
