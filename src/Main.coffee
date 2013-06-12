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

#= require CommManager.coffee
#= require TCPClient.coffee

# Settings
debugassist_port = 8080
node_host = "localhost"
node_port = 5858

# Welcome message
console.log "\n
This is a Node <-> socket.io debug proxy.\n
* Listening to localhost:#{debugassist_port}.\n
* Connected node instance: #{node_host}:#{node_port}\n
\n
Usage: Run a node server process in debug mode (node --debug ./server.js).\n
You can then run this proxy to connect to the node debugger.\n
"

fs = require "fs"

# Handler to push out static HTML file
handler = (req, res) ->
  fs.readFile __dirname + "/index.html", (err, data) ->
    if err
      res.writeHead 500
      return res.end "Error loading index.html"
    res.writeHead 200
    res.end data

# Other communication-related scaffolding
app = require("http").createServer handler
io = require("socket.io").listen app, log: false

app.listen(debugassist_port);


cm = new CommManager

io.sockets.on "connection", (socket) ->
  socket.on "debug", cm.inIO
  # Bind a callback for the output
  f = (data) =>
    socket.emit "debug", data
  cm.setOutIO f

disconnect = ->
  console.log "Disconnected from node (at #{node_host}:#{node_port})."
  process.exit()

# Set up the TCP handling as well
tcp = new TCPClient node_host, node_port
tcp.setDataCallback cm.inNode
tcp.setDisconnectCallback disconnect

cm.setOutNode tcp.sendJSON
