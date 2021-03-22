-module(router).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_cast/2, handle_call/3, handle_info/2]).


start_link() ->
    gen_server:start_link({local, router}, ?MODULE, [], []),
    dynamic_supervisor:start_link(),
    er_dynamic_supervisor:start_link(),
    auto_scaler:start_link().

init(Args) ->
    {ok, 1}.

handle_cast({tweet, Tweet}, State) ->
    NewState = round_robin_distrib(Tweet, State),
    {noreply, NewState}.


round_robin_distrib(Tweet, Index) ->
    All_Workers_List = global:registered_names(),
    Regular_Workers_List = [Pid || {regular_worker, Pid} <- All_Workers_List],
    Er_Workers_List = [Pid || {er_worker, Pid} <- All_Workers_List],
    Workers_List_Size = length(Regular_Workers_List),
    if 
        Workers_List_Size < Index ->
            gen_server:cast(lists:nth(Index, Regular_Workers_List), {tweet, Tweet}),
            gen_server:cast(lists:nth(Index, Er_Workers_List), {tweet, Tweet}),
            Index + 1;
        true ->
            gen_server:cast(lists:nth(1, Regular_Workers_List), {tweet, Tweet}),
            gen_server:cast(lists:nth(1, Er_Workers_List), {tweet, Tweet}),
            1
    end.


handle_info(Info, State) ->
    {noreply, State}.


handle_call(_,_,_) ->
    ok.