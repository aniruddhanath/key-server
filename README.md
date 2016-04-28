# key-server

Run server
--
`ruby api.rb`, server starts at `http://localhost:4567`

APIs
--
E1. `curl -X POST -d '' "http://localhost:4567/" -v` creates one new key

E2. `curl -X GET "http://localhost:4567/" -v` blocks a key

E3. `curl -X PUT -d '' "http://localhost:4567/release/:key" -v` releases a blocked key

E4. `curl -X DELETE "http://localhost:4567/:key" -v` deletes a key

E5. `curl -X PUT -d '' "http://localhost:4567/keep-alive/:key" -v` increases expiry time

Tests
--
`bin/rspec --format doc`
