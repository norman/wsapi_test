local wt = require "wsapi_test"

function hello(wsapi_env)
  local headers = { ["Content-type"] = "text/html" }
  local function hello_text()
    coroutine.yield("hello world!")
  end
  return 200, headers, coroutine.wrap(hello_text)
end

local app = wt.make_handler(hello)

do
  local response, request = app:get("/", {hello = "world"})
  assert(response.code                    == 200)
  assert(request.request_method           == "GET")
  assert(request.query_string             == "?hello=world")
  assert(response.headers["Content-type"] == "text/html")
  assert(response.body                    == "hello world!")
end
