-module(sink).
-behaviour(gen_server).
-export([init/1, start_link/0, handle_call/3, handle_cast/2, handle_info/2]).
-record(state_record, {dbconn, buffer, timer_future}).

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
    Timer_Future = start_timer_future(),
    {ok, #state_record{dbconn = DBConn, buffer = [], timer_future = Timer_Future}}.

start_timer_future() ->
    {ok, Timer_Future} = timer:send_after(5000, timeout),
    Timer_Future.

reset_timer_future(Timer_Future) ->
    {ok, Tmp} = timer:cancel(Timer_Future),
    start_timer_future().

handle_info(timeout, State) ->
    NewState = timeout_insert(State),
    {noreply, NewState}.

timeout_insert(State) ->
    insert_to_db(State#state_record.dbconn, State#state_record.buffer),
    New_Timer_Future = start_timer_future(),
    State#state_record{buffer = [], timer_future = New_Timer_Future}.

handle_cast({tweet, Tweet}, State) ->
    NewTweetBuffer = State#state_record.buffer ++ [{orig_tweet, Tweet}],
    
    NewState = try_regular_insert(State#state_record{buffer = NewTweetBuffer}),
    {noreply, NewState}.

connect_to_db() ->
    application:ensure_all_started(mongodb),
    {ok, DBConn} = mongoc:connect(?seed, ?conn_opt, ?worker_opt),
    DBConn.

try_regular_insert(State) when length(State#state_record.buffer) > 50 ->
    Tweets = lists:sublist(State#state_record.buffer, 50),
    insert_to_db(State#state_record.dbconn, Tweets),

    NewBuffer = lists:sublist(State#state_record.buffer, 51, length(State#state_record.buffer)),

    New_Timer_Future = reset_timer_future(State#state_record.timer_future),
    State#state_record{buffer = NewBuffer, timer_future = New_Timer_Future};

try_regular_insert(State) ->
    State.

get_users([], Tmp) ->
    Tmp;

get_users(Tweets, Tmp) ->
    [H|T] = Tweets,
    {_, Tweet} = H,
    User = proplists:get_value(<<"user">>, Tweet),
    get_users(T, Tmp ++ [{user, User}]).

insert_to_db(Connection, Tweets) ->
    Users = get_users(Tweets, []),
    io:format("~ninserting ~p tweets and ~p users", [length(Tweets), length(Users)]),
    mongo_api:insert(Connection, ?tweets_collection, Tweets),
    mongo_api:insert(Connection, ?users_collection, Users),
    ok.
    

handle_call(_, _, _) ->
    ok.