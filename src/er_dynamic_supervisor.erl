-module(er_dynamic_supervisor).
-behaviour(supervisor).

-export([start_link/0, init/1, add_workers/1, kill_workers/1]).

start_link() ->
    supervisor:start_link({local, er_supervisor}, ?MODULE, []),
    add_workers(3).

init(_Args) ->
    SupervisorSpecification = #{
        strategy => simple_one_for_one, 
        intensity => 10,
        period => 60},
    
    ChildSpecifications = [
        #{
            id => er_worker,
            start => {er_worker, start_link, []},
            restart => permanent,
            shutdown => infinity,
            type => worker,
            modules => [er_worker]
        }
    ],
    
    {ok, {SupervisorSpecification, ChildSpecifications}}.
    

add_workers(I) when I > 0 ->
    {ok, _} = supervisor:start_child(er_supervisor, []),
    add_workers(I - 1);

add_workers(0) ->
    ok.

kill_workers(I) ->
    Workers = supervisor:which_children(er_supervisor),
    kill_workers(I, Workers).

kill_workers(I, Workers) when length(Workers) > 3 ->
    [{_, Worker_Pid, _, _} | _] = Workers,
    supervisor:terminate_child(er_supervisor, Worker_Pid),
    kill_workers(I - 1);

kill_workers(_, _) ->
    ok.