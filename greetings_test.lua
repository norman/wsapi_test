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
