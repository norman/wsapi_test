local wt = require "wsapi_test"
wt.publish_funcs_for_testing()

print("When building a GET request")
do
  get = wt.build_get("/hello", {message = "hello world"}, {["X-Test-Header"] = "yes"})

  print("should assemble query string from params")
  assert(get.QUERY_STRING == "?message=hello+world")
end
