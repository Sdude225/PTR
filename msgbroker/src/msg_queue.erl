-module(msg_queue).
-behaviour(gen_server).

-export([start_link/0]).
-export([init/1, handle_cast/2]).

start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init(_Args) ->
    {ok, Name} = dets:open_file("durable", []),
    {ok, Name}.

handle_cast({add, Msg}, State) ->
    dets:insert(State, {msgs:get_topics(Msg), Msg}),
    {noreply, State};

handle_cast({remove, Msg}, State) -> 
    dets:delete(State, {msgs:get_topics(Msg), Msg}),
    {noreply, State}.
