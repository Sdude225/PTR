-module(router).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_cast/2, handle_call/3, handle_info/2]).


start_link() ->
    gen_server:start_link({local, router}, ?MODULE, [], []),
    auto_scaler:start_link().

init(Args) ->
    {ok, Args}.

handle_cast({tweet, Tweet}, State) ->
    {noreply, State}.

handle_info(Info, State) ->
    {noreply, State}.



handle_call(_,_,_) ->
    ok.