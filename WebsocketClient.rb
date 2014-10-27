# Require installing socket.io-client-simple

require 'socket.io-client-simple'
require 'base64'
require 'json'

$access_key = "<YOUR ACCESS KEY>"
$secret_key = "<YOUR SECRET KEY>"

def initial_post_data
  post_data = {}
  post_data['tonce']  = (Time.now.to_f * 1000000).to_i.to_s
  post_data
end

def params_string(post_data)
  post_data['params'] = post_data['params'].join(',')
  params_parse(post_data).collect{|k, v| "#{k}=#{v}"} * '&'
end

def params_parse(post_data)
  post_data['accesskey'] = $access_key #access key
  post_data['requestmethod'] = 'post'
  post_data['id'] = post_data['tonce'] unless post_data.keys.include?('id')
  fields=['tonce','accesskey','requestmethod','id','method','params']
  ordered_data = {}
  fields.each do |field|
    ordered_data[field] = post_data[field]
  end
  ordered_data
end

def sign(params_string)
  signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), $secret_key, params_string)  #secret key
  Base64.strict_encode64($access_key+ ':' + signature)
end

def initial_post_data
  post_data = {}
  post_data['tonce']  = (Time.now.to_f * 1000000).to_i.to_s
  post_data
end

socket = SocketIO::Client::Simple.connect 'https://websocket.btcchina.com'

socket.on:connect do
  puts "connected!"
  socket.emit :subscribe, "marketdata_cnybtc"
  socket.emit :subscribe, "marketdata_cnyltc"
  socket.emit :subscribe, "marketdata_btcltc"
  socket.emit :subscribe, "grouporder_cnybtc"
  socket.emit :subscribe, "grouporder_cnyltc"
  socket.emit :subscribe, "grouporder_btcltc"
  
  post_data = initial_post_data
  post_data['method'] = 'subscribe'
  post_data['params'] = ["order_cnybtc", "order_cnyltc", "order_btcltc", "account_info"]
  payload = params_parse(post_data)
  pstr = params_string(payload.clone)
  signature_string = sign(pstr)
  socket.emit :private, [payload.to_json, signature_string]
end

socket.on :disconnect do
  puts "disconnected!"
end

socket.on :message do |data|
  puts "message: "+data
end

socket.on :trade do |data|
  puts 'trade:'
  p data
end

socket.on :ticker do |data|
 puts 'ticker:'
 p data
end

socket.on :grouporder do |data|
 puts 'grouporder:'
 p data
end

socket.on :order do |data|
  puts 'order:'
  p data
end

socket.on :account_info do |data|
  puts 'account_info:'
  p data
end

loop do
  sleep 3
end
