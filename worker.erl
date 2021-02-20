-module(worker).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_call/3, handle_cast/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(Args) ->
    global:register_name(self(), self()),
    {ok, Args}.

handle_cast({tweet, Tweet}, State) ->
    % timer:sleep(rand:uniform(451) + 49),
    PropList = jsone:decode(<<Tweet>>, [{object_format, proplist}]),
    io:format("~s~n", [Tweet]),
    {noreply, State}.

handle_call(_, _, _) ->
    ok.