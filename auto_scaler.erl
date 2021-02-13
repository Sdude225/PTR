-module(auto_scaler).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_cast/2, handle_call/3, handle_info/2]).

start_link()->
    gen_server:start_link({local, auto_scaler}, ?MODULE, [], []).

init(Args) ->
    sys:statistics(router, true),
    gen_server:cast(auto_scaler, {msg_counter_init, 0}),
    {ok, Args}.

handle_cast({msg_counter_init, Previous_Len}, State) ->
    timer:sleep(1000),
    Stats = sys:statistics(router, get),
    {ok, Stats_To_List} = Stats,

    {_, Current_Len} = lists:keyfind(messages_in, 1, Stats_To_List),
    Len = Current_Len - Previous_Len,
    gen_server:cast(auto_scaler, {msg_counter_init, Current_Len}),
    {noreply, Len}.

handle_info(Msg, State) ->
    {noreply, State}.



handle_call(_, _, _) ->
    ok.