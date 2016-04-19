# key-server

Run server
--
`ruby api.rb`, server starts at `http://localhost:4567`

APIs
--
1. `curl -X POST -d '' "http://localhost:4567/"` creates one new key
2. `curl -X GET "http://localhost:4567/"` blocks a key
3. `curl -X PUT -d '' "http://localhost:4567/keep-alive/:key"` increases expiry time
4. `curl -X PUT -d '' "http://localhost:4567/release/:key"` releases a blocked key
5. `curl -X DELETE "http://localhost:4567/:key"` deletes a key

Tests
--
`bin/rspec --format doc`
