-module(dispatcher).
-export([start_dvij/1]).

start_dispatcher({Msg, Client}) -> msg_type(msg_services:get_msg_type(Msg),{Msg, Client}).

action(subscribe, {Msg, Client}) -> 
    topics:subscribe_to(msg_services:get_topics(Msg), Client);


action(unsubscribe, {Msg, Client}) -> 
    topics:unsubscribe_from(msg_services:get_topics(Msg),Client);


action(data, {Msg, _Client}) -> 
    send(msgs:is_persistent(Msg), {Msg, topics:get_topics()});


action(command, {_Msg,Client}) -> 
    tcp:send(Client, msgs:serialize(topics:get_topics()));


send(true, {Msg, Users, Topics}) -> 
    gen_server:cast(msg_queue, {add, {srv, Msg}}),
    lists:foreach(fun (Topics) -> tcp:send(Topics, msg_services:serialize(Msg)) end, Users),
    gen_server:cast(msg_queue, {msg_services:get_topics(Msg), Msg});


send(false, {Msg, Users, Topics}) -> 
    lists:foreach(fun (N) -> tcp:send(N, msg_services:serialize(Msg)) end, Users),
    gen_server:cast(msg_queue, {msg_services:get_topics(Msg), Msg}).