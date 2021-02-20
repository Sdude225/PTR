-module(message_concat).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_cast/2, handle_call/3, handle_info/2]).


start_link() ->
    router:start_link(),
    gen_server:start_link({local, message_concat}, ?MODULE, [], []).

init(Args) ->
    {ok, Args}.

handle_cast({tweet, Tweet}, State) ->
    A = is_atom(string:find(Tweet, "}\n", trailing)),
    if 
        A ->
            NewState = lists:append(State, [Tweet]),
            {noreply, NewState};

        true ->
            NewState = lists:append(State, [Tweet]),
            Split_Msg = string:split(NewState, "event: \"message\"\n\ndata:", all),
            gen_server:cast(router, {tweet, Split_Msg}),
            {noreply, []}
    end.



handle_info(Info, State) ->
    {noreply, State}.

handle_call(_,_,_) ->
    ok.