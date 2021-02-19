-module(worker).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_call/3, handle_cast/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(Args) ->
    global:register_name(self(), self()),
    io:format("Worker ~p started~n", [self()]),
    {ok, Args}.

handle_cast({tweet, Tweet}, State) ->
    {ok, State}.

handle_call(_, _, _) ->
    ok.