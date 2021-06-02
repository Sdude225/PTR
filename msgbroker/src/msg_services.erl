-module(msg_services).


serialize(Msg) -> mochijson2:encode([Msg#msg.header, Msg#msg.body]).

deserialize(Msg) ->
    Fmsg = mochijson2:decode(Msg),
    #msg{header = get_header(Fmsg), body = get_body(Fmsg)}.

get_header(Msg) -> ej:get({first}, Msg).

get_body(Msg) ->
    Body = ej:get({last}, Msg),
    Body.

get_msg_type(Msg) ->
    [Type | _] = Msg#msg.header,
    list_to_atom(binary_to_list(Type)).

is_persistent(Msg) ->
    [_|[Pers | _]] = Msg#msg.header,
    Pers.

get_topics(Msg) ->
    [_|[Topics | _]] = Msg#msg.header,
    [list_to_atom(Tmp) || Tmp <- Topics].