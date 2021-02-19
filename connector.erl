-module(connector).
-export([init/0, request/1, conn_inf_loop/1]).


init() ->
    inets:start(),
    message_concat:start_link(),
    register(conn1, spawn(?MODULE, request, ["http://localhost:4001/tweets/1"])),
    register(conn2, spawn(?MODULE, request, ["http://localhost:4001/tweets/2"])).

request(Request) ->
    httpc:request(get, {Request, []}, [], [{sync, false}, {stream, self}]),
    conn_inf_loop(Request).

conn_inf_loop(Request) ->
    receive
        {http, {_, {error, socket_closed_remotely}}} ->
            request(Request);
        {http, {_, stream, Tweet}} ->
            gen_server:cast(message_concat, {tweet, Tweet}),
            conn_inf_loop(Request)
    end.