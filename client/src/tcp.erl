-module(tcp).
-export([listen/1, accept/1, connect/1, send/2, read/1, close/1]).

listen(Port) -> 
    gen_tcp:listen(Port, [binary, {packet, 0}, {active, true}, {reuseaddr, true}]).


accept(Socket) -> 
    gen_tcp:accept(Socket).


connect(Port) -> 
    gen_tcp:connect("localhost", Port, [binary, {packet, 0}, {active, false}]).


close(Socket) -> 
    gen_tcp:close(Socket).


send(Socket, Data) -> 
    gen_tcp:send(Socket, Data).


read(Sock) -> 
    {ok, Msg} = gen_tcp:recv(Socket, 0), Msg.