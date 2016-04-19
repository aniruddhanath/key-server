require 'sinatra'
require 'JSON'

require File.dirname(__FILE__) + '/classes/keys'
keys = Keys.new()

post '/' do
  keys.create
  status 201
end

get '/' do
  keys.fetch.to_json
end

put '/release/:key' do
  keys.update(params[:key], 1)
  status 200
end

put '/keep-alive/:key' do
  keys.update(params[:key])
  status 200
end

delete '/:key' do
  keys.delete(params[:key])
  status 200
end

def _every_n_seconds(n)
  loop do
    before = Time.now
    yield
    interval = n - (Time.now - before)
    sleep(interval) if interval > 0
  end
end

Thread.new do
  _every_n_seconds(10) {
    keys.delete_if_expired
  }
end

Thread.new do
  _every_n_seconds(60) {
    keys.release_keys
  }
end

# keys = Keys.new()
# fetched_keys = []

# keys.delete_if_expired

# (1..10).each {
#   keys.create
# }

# def condition_check(keys)
#   keys.each do |key, status|
#     puts "#{key} : #{status}"
#   end
# end

# puts "after creation..."
# condition_check(keys.keys_hash)
# keys.get_available

# puts "fetched first 2.."
# (1..2).each {
#   a = keys.fetch
#   fetched_keys.push(a)
#   puts a
# }
# condition_check(keys.keys_hash)
# keys.get_available

# keys.update(fetched_keys[0], 1)
# puts "after updating.."
# condition_check(keys.keys_hash)
# keys.get_available

# puts "again fetching 2"
# (1..2).each {
#   a = keys.fetch
#   fetched_keys.push(a)
#   puts a
# }
# condition_check(keys.keys_hash)
# keys.get_available

# k = keys.get_available[0]
# puts "deleting #{k}..."
# keys.delete(k)

# condition_check(keys.keys_hash)
# keys.get_available

# puts "after deletion trying to fetch..."
# a = keys.fetch
# fetched_keys.push(a)
# puts a
# condition_check(keys.keys_hash)
# keys.get_available

# condition_check(keys.keys_hash)
