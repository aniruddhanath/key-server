require 'securerandom'
require File.expand_path("../log.rb", __FILE__)
require File.expand_path("../error.rb", __FILE__)

include Log

class Keys
  attr_reader :keys_hash

  AVAILABLE = 1
  BLOCKED = 0
  EXPIRY = 300 # 5 minutes

  def initialize
    @keys_hash = Hash.new()
    @available_keys = []
    @blocked_keys = []
  end

  private
  def _is_available?(key)
    !@keys_hash[key].nil? && @keys_hash[key][:status] == AVAILABLE
  end

  def _add_to_available(key)
    @available_keys.push(key)
  end

  def _add_to_blocked(key)
    @blocked_keys.push(key)
  end

  public
  def create
    key = ("BST_" + SecureRandom.hex + "_" +Time.now.to_i.to_s).to_sym
    @keys_hash[key] = { status: AVAILABLE }
    _add_to_available(key)
    Log.success("[ created #{key} : #{@keys_hash[key]} ]")
  end

  def fetch
    if @available_keys.size == 0
      return
    end

    key = @available_keys.shift;
    while !_is_available?(key) && !key.nil?
      key = @available_keys.shift
    end
    @keys_hash[key] = { status: BLOCKED, expiry: Time.now.to_i + EXPIRY }
    Log.success("[ blocked #{key} : #{@keys_hash[key]} ]")
    _add_to_blocked(key)
    key;
  end

  def update(key, status = false)
    raise KeyNotFound, "Key not found" unless @keys_hash.has_key?(key.to_sym)
    
    # call for keep-alive
    if !status
      @keys_hash[key.to_sym][:expiry] = Time.now.to_i + EXPIRY
      Log.success("[ keep-alive applied to #{key} : #{@keys_hash[key.to_sym]} ]")
      return
    end

    # call for updating status
    old_status = @keys_hash[key.to_sym][:status]
    _add_to_available(key.to_sym) if old_status != status && status == AVAILABLE
    @keys_hash[key.to_sym] = { status: AVAILABLE }
    Log.success("[ releasing #{key} : #{@keys_hash[key.to_sym]} ]")
  end

  def delete(key)
    raise KeyNotFound, "Key not found" unless @keys_hash.has_key?(key.to_sym)
    @keys_hash.delete(key.to_sym)
    Log.success("[ deleted #{key} ]")
  end

  def get_blocked_keys
    @blocked_keys
  end

  def delete_if_expired
    Log.info("[ checking expired keys at time: " + Time.now.to_i.to_s + " ]")
    @keys_hash.each do |key, value|
      puts "#{key} : #{value}"
      if !value[:expiry].nil? && value[:expiry] < Time.now.to_i 
        @keys_hash.delete(key) if value[:status] == BLOCKED
      end
    end
  end

  def release_keys
    Log.info("[ checking blocked keys at time: " + Time.now.to_i.to_s + " ]")
    blocked_key = @blocked_keys.shift
    while !blocked_key.nil?
      puts blocked_key
      if  @keys_hash.has_key?(blocked_key) && @keys_hash[blocked_key][:status] == BLOCKED
        # check if already present in @available_keys
        @available_keys.push(blocked_key.to_sym) unless @available_keys.include?(blocked_key.to_sym)
        @keys_hash[blocked_key.to_sym] = { status: AVAILABLE }
      end
      blocked_key = @blocked_keys.shift
    end
  end
end
