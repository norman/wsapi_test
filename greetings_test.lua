local wt = require "wsapi_test"

local app = wt.make_handler(require 'greetings')

do
  local response = app:get("/")
  print("should get index page")
  assert(response.code == 200)
end

do
  local response = app:get("/dsadasdsa")
  print("should get 404")
  assert(response.code == 404)
end

do
  local response = app:get("/say_hi/en/Joe/")
  print("should get English greeting")
  assert(response.code == 200)
  assert(response.body:match("Hi Joe"))
end

do
  local response = app:get("/say_hi/it/Joe/")
  print("should get Italian greeting")
  assert(response.code == 200)
  assert(response.body:match("Ciao Joe"))
end

do
  local response = app:post("/say_hi", {name = "Joe", lang = "en"})
  print("Should get English greeting via POST")
  assert(response.code == 200)
  assert(response.body:match("Hi Joe"))
end

do
  local response = app:post("/say_hi")
  print("Should get error message when no name is posted")
  assert(response.code == 200)
  assert(response.body:match("have no name"))
end

