-module(aggregator).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_cast/2, handle_call/3]).

start_link() ->
    gen_server:start_link({local, aggregator}, ?MODULE, [], []).

init(Args) ->
    ets:new(ets_table, [ordered_set, public, named_table]),
    {ok, Args}.

handle_cast({tweet, ID, Tweet}, State) ->
    handle_panic_messages(proplists:get_value(<<"message">>, Tweet), ID, Tweet),
    {noreply, State};

handle_cast({emotion_value, ID, Emotion_Value}, State) ->
    [{_, Tweet}] = ets:match_object(ets_table, {ID, '_'}),
    update_tweet(proplists:get_value(<<"engagement_ratio">>, Tweet), Tweet, ID, {<<"emotion_value">>, Emotion_Value}),
    {noreply, State};

handle_cast({engagement_ratio, ID, Engagement_Ratio}, State) ->
    [{_, Tweet}] = ets:match_object(ets_table, {ID, '_'}),
    update_tweet(proplists:get_value(<<"emotion_value">>, Tweet), Tweet, ID, {<<"engagement_ratio">>, Engagement_Ratio}),
    {noreply, State}.

update_tweet(undefined, Tweet, ID, Value) ->
    Updated_Tweet = lists:append(Tweet, [Value]),
    ets:insert(ets_table, {ID, Updated_Tweet});

update_tweet(_, Tweet, ID, Value) ->
    Updated_Tweet = lists:append(Tweet, [Value]),
    gen_server:cast(sink, {tweet, Updated_Tweet}),
    ets:delete(ets_table, ID).

handle_panic_messages(undefined, ID, Tweet) ->
    ets:insert(ets_table, {ID, Tweet});

handle_panic_messages(_, ID, Tweet) ->
    ok.


handle_call(_, _, _) ->
    ok.