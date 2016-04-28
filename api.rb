require 'sinatra'
require 'JSON'

require File.dirname(__FILE__) + '/classes/keys'
keys = Keys.new()

post '/' do
  keys.create
  status 201
end

get '/' do
  key = keys.fetch
  if key.nil?
    status 404
    return
  end
  body key.to_json
  status 200
end

put '/release/:key' do
  begin
    keys.update(params[:key], Keys::AVAILABLE)
  rescue KeyNotFound => err
    body err.to_json
    status 404
  else
    status 200
  end
end

put '/keep-alive/:key' do
  begin
    keys.update(params[:key])
  rescue KeyNotFound => err
    body err.to_json
    status 404
  else
    status 200
  end
end

delete '/:key' do
  begin
    keys.delete(params[:key])
  rescue KeyNotFound => err
    body err.to_json
    status 404
  else
    status 200
  end
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
