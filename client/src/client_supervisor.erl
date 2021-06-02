-module(client_supervisor).
-behaviour(supervisor).

-export([start_link/0, init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, Socket} = tcp:connect(17017),
    SupFlags = #{strategy => one_for_all,
                 intensity => 0,
                 period => 1},
    ChildSpecs = [
        #{
        id => client,
        start => {client, start_link, [Socket]},
        restart => permanent,
        shutdown => infinity,
        type => worker,
        modules => [client]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.