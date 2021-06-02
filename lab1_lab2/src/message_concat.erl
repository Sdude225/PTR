-module(message_concat).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_cast/2, handle_call/3, handle_info/2]).


start_link() ->
    router:start_link(),
    gen_server:start_link({local, message_concat}, ?MODULE, [], []).

init(Args) ->
    {ok, Args}.

handle_cast({tweet, Tweet}, State) ->
    % io:format("~n~n~n~p~n~n~n", [Tweet]),
    A = lists:suffix([125, 10, 10], binary_to_list(Tweet)),
    % A = is_atom(string:find(Tweet, "}\n", trailing)),
    if 
        A == false ->
            NewState = string:concat(State, binary_to_list(Tweet)),
            {noreply, NewState};

        true ->
            NewState = string:concat(State, binary_to_list(Tweet)),
            % io:format("~n~n~n~s~n~n~n", [NewState]),
            Split_Msg = string:split(NewState, "event: \"message\"\n\ndata:", all),
            % [io:format("//////////////////////~n~n~n~s~n~n~n", [Tmp]) || Tmp <- Split_Msg, string:is_empty(Tmp) /= true],
            [gen_server:cast(router, {tweet, Tmp}) || Tmp <- Split_Msg, string:is_empty(Tmp) /= true],
            % io:format("~n~n~npizdanahui~n~n~n"),
            {noreply, []}
    end.



handle_info(Info, State) ->
    {noreply, State}.

handle_call(_,_,_) ->
    ok.

%gen_server:cast(router, {tweet, Tmp})