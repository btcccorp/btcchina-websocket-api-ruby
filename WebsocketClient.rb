# Require installing socket.io-client-simple

require 'socket.io-client-simple'

socket = SocketIO::Client::Simple.connect 'https://websocket.btcchina.com'

socket.on :connect do
  puts "connect!!!"
  socket.emit :subscribe, "marketdata_cnybtc"
  socket.emit :subscribe, "marketdata_cnyltc"
  socket.emit :subscribe, "marketdata_btcltc"
end

socket.on :disconnect do
  puts "disconnected!!"
end

socket.on :trade do |data|
  puts 'trade:'
  p data
end

loop do
end