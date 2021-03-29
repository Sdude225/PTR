-module(sink).
-behaviour(gen_server).
-export([init/1, start_link/0, handle_call/3, handle_cast/2]).

-define(conn_opt, [
    { name,  mongoc },    
    { register,  mongo_topology },    
    { pool_size, 5 }, 
    { max_overflow, 10 },	
    { overflow_ttl, 1000 }, 
    { overflow_check_period, 1000 }, 
    { localThresholdMS, 1000 }, 
    { connectTimeoutMS, 20000 },
    { socketTimeoutMS, 100 },
    { serverSelectionTimeoutMS, 30000 },
    { waitQueueTimeoutMS, 1000 }, 
    { heartbeatFrequencyMS, 10000 },  
    { minHeartbeatFrequencyMS, 1000 },
    { rp_mode, primary }, 
    { rp_tags, [{tag,1}]}
]).

-define(worker_opt, [
    {database, <<"prlab">>},
    {login, <<"sysadmin">>},
    {password, <<"des66362">>},
    {ssl, true}
]).

-define(tweets_collection, <<"tweets">>).
-define(users_collection, <<"users">>).
-define(seed, {rs, <<"atlas-zc87gu-shard-0">>, [
    "prlab-shard-00-00.j1yj9.mongodb.net:27017",
    "prlab-shard-00-01.j1yj9.mongodb.net:27017",
    "prlab-shard-00-02.j1yj9.mongodb.net:27017"    
]}).

start_link() ->
    gen_server:start_link({local, sink}, ?MODULE, [], []).

init(_Args) ->
    DBConn = connect_to_db(),
    {ok, DBConn}.

handle_cast({tweet, Tweet}, State) ->
    % mongo_api:insert(State, ?tweets_collection, [Tweet]),
    % io:format("~n~n~n~p~n~n~n", [Tweet]),
    {noreply, State}.

connect_to_db() ->
    application:ensure_all_started(mongodb),
    {ok, DBConn} = mongoc:connect(?seed, ?conn_opt, ?worker_opt),
    DBConn.

handle_call(_, _, _) ->
    ok.