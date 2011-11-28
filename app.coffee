#Includes
express = require 'express'
app = module.exports = express.createServer()

#Configuration
app.configure () ->
    app.set 'views', "#{__dirname}/views"
    app.set 'view engine', 'jade'
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use require('stylus').middleware( src: "#{__dirname}/public" )
    app.use app.router
    app.use express.static( "#{__dirname}/public")
    app.use express.errorHandler

#State

###
Message format
{id: int, author: string, message: string}
###
messageIndex = 1
messages     = []

#Array of waiting recievers
#Called with no arguments, put everything needed in a closure
recvQueue = []

messagesSinceId = (id) -> m for m in messages when m.id > id

sendMessage = (author, message) ->
    messages.push
        id:      messageIndex++
        author:  author
        message: message

    messages.shift() while messages.length > 10

    # Shift-n-call
    recvQueue.shift()() while recvQueue.length > 0

registerWaiter = (res, id) ->
    recvQueue.push () ->
        res.json messagesSinceId(id)

#Routes
app.get '/', (req, res) ->
    res.render 'index',
        title: 'Chat'

app.get '/chat/:id?', (req, res, next) ->
    id = parseInt(req.param('id'))
    if !id? || !(id >= 0) then next()
    else
        newMessages = messagesSinceId(id)
        if newMessages.length > 0 then res.json newMessages
        else registerWaiter res, id

app.get '/chat/new', (req, res) ->
    registerWaiter res, messageIndex-1

app.post '/chat/new', (req, res) ->
    sendMessage  req.param('author'), req.param('message')
    res.json {result:'success'}

#Server start
app.listen(process.env.PORT || 3000)
console.log "Server started on port #{app.address().port} in #{app.settings.env} mode"