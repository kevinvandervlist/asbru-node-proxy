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

class TCPClient
  constructor: (@host, @port, autoconnect = true) ->
    @net = require "net"
    @connected = false
    @conn = null
    @dataCallback = null
    @queue = []
    @connect() if autoconnect
    @disconnectCallback = null

  setDataCallback: (cb) ->
    @dataCallback = cb

  setDisconnectCallback: (cb) ->
    @disconnectCallback = cb

  connect: ->
    @conn = @net.connect {host: @host, port: @port}
    @conn.setEncoding('utf8');

    @conn.on "connect", @_onConnect
    @conn.on "data", @_onData
    @conn.on "error", @_onError
    @conn.on "end", @_onEnd
    @conn.on "close", @_onClose

  sendMessage: (message) =>
    if not @connected
      @_queue message
      return undefined

    data = "Content-Length: #{message.length}\r\n\r\n#{message}"
    @conn.write data

  sendJSON: (json) =>
    @sendMessage JSON.stringify(json)

  # Socket callback stuff

  _onConnect: =>
    @connected = true
    @sendMessage message for message in @queue

  _onData: (data) =>
    @dataCallback(data) if @dataCallback

  _onError: (error) =>
    throw error

  _onEnd: =>
    @conn.end()
    @disconnectCallback() if @disconnectCallback?

  _onClose: =>
    @connected = false
    @queue = []
    @conn.destroy()

  # A queue with messages if the connection is being established
  _queue: (message) ->
    @queue.push message
