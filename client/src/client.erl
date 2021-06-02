-module(client).
-behaviour(gen_server).

-export([start_link/1]).
-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2]).

-record(state, {socket}).

start_link(Socket) -> gen_server:start_link({local, ?MODULE},?MODULE, Socket, []).

init(Socket) ->
    gen_server:cast(self(), connect),
    {ok, #state{socket=Socket}}.


handle_cast(connect, State) ->
    Client = State#state.socket,
    gen_tcp:controlling_process(Client, self()),  
    {noreply, State#state{socket = Client}};


handle_info({receive_msg, Msg}, State) ->
    Data = msgs:deserialize(Msg),
    io:format("Incoming message~n",[Data]),
    {noreply, State};


handle_info(Msg, State) ->
    io:format("Sending~n",[Msg]),
    Data = msgs:serialize(Msg),
    tcp:send(State#state.socket, Data),
    {noreply, State}.
           