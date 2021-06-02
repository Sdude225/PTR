-module(msg_services).
-export([serialize/1, deserialize/1, build_msg/0, add_header/2, add_body/2]).

serialize(Msg) -> mochijson2:encode([Msg#msg.header, Msg#msg.body]).

deserialize(Msg) ->
    Fmsg = mochijson2:decode(Msg),
    #msg{header = get_header(Fmsg), body = get_body(Fmsg)}.

get_header(Msg) -> ej:get({first}, Msg).

get_body(Msg) ->
    Body = ej:get({last}, Msg),
    Body.

build_msg() -> 
    #msg{header = null, body = null}.


add_header(Msg, Header) -> 
    Msg#msg{header = Header}.


add_body(Msg, Body) -> 
    Msg#msg{body = Body}.