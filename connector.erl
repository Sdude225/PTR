-module(connector).
-export([init/0, request/1, conn_inf_loop/0]).


init() ->
    inets:start(),
    router:start_link(),
    register(conn1, spawn(?MODULE, request, ["http://localhost:4001/tweets/1"])),
    register(conn2, spawn(?MODULE, request, ["http://localhost:4001/tweets/2"])).

request(Request) ->
    httpc:request(get, {Request, []}, [], [{sync, false}, {stream, self}]),
    conn_inf_loop().

conn_inf_loop() ->
    receive
        Tweet ->
            gen_server:cast(router, {tweet, Tweet}),
            conn_inf_loop()
    end.