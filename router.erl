-module(router).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_cast/2, handle_call/3, handle_info/2]).


start_link() ->
    gen_server:start_link({local, router}, ?MODULE, [], []).

init(Args) ->
    {ok, Args}.

handle_cast({tweet, Tweet}, State) ->
    A = is_atom(string:find(Tweet, "}\n\n", trailing)),
    if 
        A == true ->
            NewState = lists:append(State, [Tweet]),
            {noreply, NewState};

        A == false ->
            NewState = lists:append(State, [Tweet]),
            io:format("~s~n////////////////////", [NewState]),
            {noreply, []}
    end.

handle_info(Info, State) ->
    {noreply, State}.



handle_call(_,_,_) ->
    ok.