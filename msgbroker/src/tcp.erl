-module(tcp).
-export([listen/1, accept/1, connect/1, send/2, read/1, close/1]).

listen(Port) -> 
    gen_tcp:listen(Port, [binary, {packet, 0}, {active, true}, {reuseaddr, true}]).


accept(Sock) -> 
    gen_tcp:accept(Sock).


connect(Port) -> 
    gen_tcp:connect("localhost", Port, [binary, {packet, 0}, {active, false}]).


close(Sock) -> 
    gen_tcp:close(Sock).


send(Sock, Data) -> 
    gen_tcp:send(Sock, Data).


read(Sock) -> 
    {ok, Msg} = gen_tcp:recv(Sock, 0), Msg.