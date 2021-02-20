-module(router).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_cast/2, handle_call/3, handle_info/2]).


start_link() ->
    gen_server:start_link({local, router}, ?MODULE, [], []),
    dynamic_supervisor:start_link(),
    auto_scaler:start_link().

init(Args) ->
    {ok, 1}.

handle_cast({tweet, Tweet}, State) ->
    NewState = round_robin_distrib(Tweet, State),
    {noreply, NewState}.


round_robin_distrib(Tweet, Index) ->
    Workers_List = global:registered_names(),
    Workers_List_Size = length(Workers_List),
    if 
        Workers_List_Size < Index ->
            gen_server:cast(lists:nth(Index, Workers_List), {tweet, Tweet}),
            Index + 1;
        true ->
            gen_server:cast(lists:nth(1, Workers_List), {tweet, Tweet}),
            1
    end.


handle_info(Info, State) ->
    {noreply, State}.


handle_call(_,_,_) ->
    ok.