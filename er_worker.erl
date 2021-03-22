-module(er_worker).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_call/3, handle_cast/2, terminate/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(Args) ->
    global:register_name({er_worker, self()}, self()),
    {ok, Args}.

handle_cast({tweet, Tweet}, State) ->
    timer:sleep(rand:uniform(451) + 49),
    PropList = jsone:decode(list_to_binary([Tweet]), [{object_format, proplist}]),
    io:format("~p~n~n//////////////////", [PropList]),
    {noreply, State}.

terminate(Reason, State) ->
    io:format("Terminating child ~p", [self()]),
    ok.

handle_call(_, _, _) ->
    ok.