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

class NodeMessage
  # Thanks: node-inspector -> lib/debugger.js
  # https://github.com/dannycoates/node-inspector
  constructor: (rawdata) ->
    @complete = false
    @headers = null
    @contentLength = null
    @type = null
    @body = null
    @size = -1

    # Find the offset of content-length header
    offset = rawdata.indexOf('\r\n\r\n');
    if offset <= 0
      return undefined

    # Store the headers, +4 because of linebreaks
    @headers = rawdata.substr(0, offset + 4);

    # Store the content length
    contentLengthMatch = /Content-Length: (\d+)/.exec(@headers)
    if contentLengthMatch[1]
      @contentLength = parseInt contentLengthMatch[1], 10
    else
      throw "No Content-Length found"

    # Is this a message with a body at all? Otherwise complete, but without body
    if @contentLength is 0
      @size = @headers.length
      return undefined

    # Parse the body
    debugBuffer = rawdata.slice(offset + 4);
    if Buffer.byteLength(debugBuffer) >= @contentLength
      b = new Buffer debugBuffer
      @rawbody = b.toString "utf8", 0, @contentLength
      debugBuffer = b.toString "utf8", @contentLength, b.length
      if @rawbody.length > 0
        @body = JSON.parse(@rawbody);

    # If the body is parsed, set type and flag as complete
    if @body?.type?
      @type = @body.type
      @size = @headers.length + @rawbody.length

  isComplete: ->
    @size isnt -1

  getType: ->
    @type

  getBody: ->
    @body

  getContentLength: ->
    @contentLength

  getHeaders: ->
    @headers

  getSize: ->
    @size
