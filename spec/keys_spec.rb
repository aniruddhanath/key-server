require File.expand_path("../../classes/keys.rb", __FILE__)

RSpec.describe Keys, "#check" do

  keys = Keys.new
  fetched_keys = []

  context "Checking `Keys` class methods" do
    it "creates 10 keys" do
      (1..10).each {
        keys.create
      }
      keys.keys_hash.each do |key, value|
        expect(value[:status]).to equal(1)
      end
    end
  
    it "picks, blocks, sets expiry to 2 keys" do
      (1..2).each {
        fetched_keys.push(keys.fetch)
      }
      fetched_keys.each do |key|
        expect(keys.keys_hash[key][:status]).to equal(0)
        expect(keys.keys_hash[key].has_key?(:expiry)).to equal(true)
      end
      expect(fetched_keys.size).to equal(2)
    end

    it "checks expiry-time on calling keep-alive for the first key" do
      sleep(1)
      old_expiry = keys.keys_hash[fetched_keys[0].to_sym][:expiry]
      keys.update(fetched_keys[0])
      expect(keys.keys_hash[fetched_keys[0].to_sym][:expiry]).to be > old_expiry
    end

    it "releases the first key" do
      keys.update(fetched_keys[0], Keys::AVAILABLE)
      expect(keys.keys_hash[fetched_keys[0].to_sym][:status]).to equal(1)
    end

    it "deletes the first key" do
      keys.delete(fetched_keys[0])
      expect(keys.keys_hash.has_key?(fetched_keys[0].to_sym)).to equal(false)
    end

    it "checks if no blocked key remains after calling `release_keys`" do
      keys.release_keys
      expect(keys.get_blocked_keys.size).to equal(0)
    end
  end

end
