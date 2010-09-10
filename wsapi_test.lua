module(..., package.seeall)

local wsapi = {}
wsapi.common  = require "wsapi.common"
wsapi.request = require "wsapi.request"
wsapi.util    = require "wsapi.util"

local function build_request(method, path, headers)
  local req = {
    GATEWAY_INTERFACE    = "CGI/1.1",
    HTTP_ACCEPT          = "application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5",
    HTTP_ACCEPT_CHARSET  = "ISO-8859-1,utf-8;q=0.7,*;q=0.3",
    HTTP_ACCEPT_ENCODING = "gzip,deflate,sdch",
    HTTP_ACCEPT_LANGUAGE = "en-US,en;q=0.8",
    HTTP_CACHE_CONTROL   = "max-age=0",
    HTTP_CONNECTION      = "keep-alive",
    HTTP_HOST            = "127.0.0.1:80",
    HTTP_USER_AGENT      = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_4; en-US) AppleWebKit/534.3 (KHTML, like Gecko) Chrome/6.0.472.55",
    HTTP_VERSION         = "HTTP/1.1",
    REMOTE_ADDR          = "127.0.0.1",
    REMOTE_HOST          = "localhost",
    SCRIPT_NAME          = "wsapi_test",
    SERVER_NAME          = "localhost",
    SERVER_PORT          = "80",
    SERVER_PROTOCOL      = "HTTP/1.1"
  }

  req.PATH_INFO      = path
  req.REQUEST_METHOD = method:upper()
  req.METHOD         = req.REQUEST_METHOD
  req.REQUEST_PATH   = "/"

  if req.PATH_INFO == "" then req.PATH_INFO = "/" end

  -- allow case-insensitive table key access
  setmetatable(req, {__index = function(t, k)
    return rawget(t, string.upper(k))
  end})
  return req
end

function wsapi.common.send_output(out, status, headers, res_iter, write_method, res_line)
   wsapi.common.send_content(out, res_iter, out:write())
end

local function make_io_object()
  local buffer = {}
  local receiver = {}
  function receiver:write(content)
    table.insert(buffer, content)
  end

  function receiver:read()
    return table.concat(buffer)
  end

  function receiver:clear()
    buffer = {}
  end
  return receiver
end

local function build_get(path, params, headers)
  local req = build_request("GET", path, headers)

  req.QUERY_STRING = wsapi.request.methods.qs_encode(nil, params)
  req.REQUEST_URI  = "http://" .. req.HTTP_HOST .. req.PATH_INFO .. req.QUERY_STRING

  for k, v in pairs(headers or {}) do req[k] = v end

  return {
    env    = req,
    input  = make_io_object(),
    output = make_io_object(),
    error  = make_io_object()
  }
end

local function build_post(path, params, headers)
end

local methods = {}

function methods:get(path, params, headers)
  local wsapi_env = build_get(path, params, headers)
  local response = {}
  response.code, response.headers = wsapi.common.run(self.app, wsapi_env)
  response.body = wsapi_env.output:read()
  return response, wsapi_env.env
end


function make_handler(app)
  local handler = {app = app}
  setmetatable(handler, {__index = methods})
  return handler
end

function publish_funcs_for_testing()
  _M.build_get = build_get
end
