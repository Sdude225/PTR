-module(broker).
-behaviour(gen_server).

%% API
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).

-record(state, {socket}).

start_link(Socket) -> gen_server:start_link(?MODULE, Socket, []).

init(Socket) ->
    {ok, Port} = application:get_env(17014),
    {ok, LSocket} = tcp:listen(Port),
    gen_server:cast(self(), accept),
    {ok, #state{socket=Socket}}.

handle_cast(accept, State) ->
    {ok, Client} = tcp:accept(State#state.user_socket),
    gen_tcp:controlling_process(Client, self()),
    broker_sup:start_socket(),  
    {noreply, State#state{socket = Client}};


handle_info({tcp, Socket, <<"quit">>}, State) ->
    tcp:close(Socket),
    {stop, normal, State};

handle_info({tcp, Socket, Msg}, State) ->
    Data = msgs:deserialize(Msg),
    dispatcher:start_dispatcher({Data, Socket}),
    {noreply, State};
           
handle_info({tcp_closed, _Socket}, State) -> 
    {stop, normal, State};


handle_info({tcp_error, _Socket, _}, State) -> 
    {stop, normal, State};


handle_call(stop, _From, State) -> 
    {stop, normal, stopped, State}.
