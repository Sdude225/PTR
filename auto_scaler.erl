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
    change_workers_number(Len),
    io:format("Workers : ~p~n Messages : ~p~n", [global:registered_names(), Len]),
    gen_server:cast(auto_scaler, {msg_counter_init, Current_Len}),
    {noreply, Len}.


change_workers_number(Num_of_msgs) ->
    Required_num_workers = Num_of_msgs div 10,
    Difference = Required_num_workers - proplists:get_value(workers, supervisor:count_children(supervisor)),
    if 
        Difference >= 0 -> 
            dynamic_supervisor:add_workers(Difference);

        true -> 
            dynamic_supervisor:kill_workers(-Difference)
    end,
    ok.



handle_info(Msg, State) ->
    {noreply, State}.

handle_call(_, _, _) ->
    ok.