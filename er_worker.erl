-module(er_worker).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_call/3, handle_cast/2, terminate/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(Args) ->
    process_flag(trap_exit, true),
    global:register_name({er_worker, self()}, self()),
    {ok, Args}.

handle_cast({tweet, ID, Tweet}, State) ->
    timer:sleep(rand:uniform(451) + 49),

    check_message_type(proplists:get_value(<<"message">>, Tweet), Tweet, ID),
    % io:format("~n~n~nmsg ID: ~p~nworkerid: ~p~n erworker~n~n~n", [ID, self()]),

    {noreply, State}.


check_message_type(<<"panic">>, _, ID) ->
    exit(self(), kill);

check_message_type(undefined, Tweet, ID) ->
    User_Info_Field = proplists:get_value(<<"user">>, Tweet),

    Followers_Count = proplists:get_value(<<"followers_count">>, User_Info_Field),
    Retweet_Count = proplists:get_value(<<"retweet_count">>, Tweet),
    Favorite_Count = proplists:get_value(<<"favorite_count">>, Tweet),

    check_tweet(Followers_Count, Retweet_Count, Favorite_Count, ID).

% check_message_type(_, Tweet, ID) ->
%     [{<<"message">>, [{<<"tweet">>, Tweet_Info_Field}, _]}] = Tweet,
%     User_Info_Field = proplists:get_value(<<"user">>, Tweet_Info_Field),

%     Followers_Count = proplists:get_value(<<"followers_count">>, User_Info_Field),
%     Retweet_Count = proplists:get_value(<<"retweet_count">>, Tweet_Info_Field),
%     Favorite_Count = proplists:get_value(<<"favorite_count">>, Tweet_Info_Field),

%     check_tweet(Followers_Count, Retweet_Count, Favorite_Count, ID).

check_tweet(0, Retweet_Count, Favorite_Count, ID) ->
    gen_server:cast(aggregator, {engagement_ratio, ID, (Retweet_Count + Favorite_Count) / 1});

check_tweet(Followers_Count, Retweet_Count, Favorite_Count, ID) ->
    gen_server:cast(aggregator, {engagement_ratio, ID, (Retweet_Count + Favorite_Count) / Followers_Count}).


terminate(Reason, State) ->
    % io:format("Terminating child ~p", [self()]),
    ok.

handle_call(_, _, _) ->
    ok.

%"followers_count" in user
%retweet_count in tweet
%favorite_count in tweet