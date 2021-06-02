-module(topics).
-export([subscribe_to/2, unsubscribe_from/2, get_topics/0, new_topic/1]).

subscribe_to(Topics, Client)->
    add(Topics,Client,ets:tab2list(topics),[]).

add([H|Ts], Client, Q, Acc) ->
    T=[{H, [Client|proplists:get_value(H,Q)]}|Acc],
    add(Ts,Client,Q,T);


unsubscribe_from(Topics, Client) -> 
    Topic_To_Be_Removed = remove(Topics,Client,ets:tab2list(topics),[]),
    ets:delete_all_objects(Topic_To_Be_Removed),

remove([H|Ts], Client, Q, Acc) ->
    T=[{H, lists:delete(Client,proplists:get_value(H,Q))} | Acc],
    remove(Ts,Client,Q,T);


get_topics() -> 
    proplists:get_keys(ets:tab2list(topics)).

new_topic(Topic) -> 
    ets:insert(topics, {Topic, []}).