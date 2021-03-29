-module(router).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_cast/2, handle_call/3, handle_info/2]).


start_link() ->
    gen_server:start_link({local, router}, ?MODULE, [], []),
    dynamic_supervisor:start_link(),
    er_dynamic_supervisor:start_link(),
    auto_scaler:start_link(),
    aggregator:start_link().

init(Args) ->
    {ok, 1}.

handle_cast({tweet, Tweet}, State) ->
    NewState = round_robin_distrib(Tweet, State),
    {noreply, NewState}.


round_robin_distrib(Tweet, Index) ->
    % io:format("~n~n~nTweet:~n~n~s~n~n~n", [Tweet]),
    Fixed_Tweet = fix_panic_msg(Tweet),
    io:format("~n~n~nTweet:~n~n~s~n~n~nFixedTweet:~n~n~p~n~n~n", [Tweet, Fixed_Tweet]),
    Tweets = check_retweet_status(Fixed_Tweet, proplists:get_value(<<"message">>, Fixed_Tweet, not_found)),

    IDed_Tweets = lists:zip([erlang:unique_integer([positive, monotonic]) || _ <- Tweets], Tweets),

    [gen_server:cast(aggregator, {tweet, ID, _Tweet}) || {ID, _Tweet} <- IDed_Tweets],

    All_Workers_List = global:registered_names(),
    Regular_Workers_List = [Pid || {regular_worker, Pid} <- All_Workers_List],
    Er_Workers_List = [Pid || {er_worker, Pid} <- All_Workers_List],
    Workers_List_Size = length(Regular_Workers_List),

    if 
        Workers_List_Size > Index ->
            [cast_to_workers(Index, Regular_Workers_List, Er_Workers_List, Tmp) || Tmp <- IDed_Tweets],
            Index + 1;
        true ->
            [cast_to_workers(1, Regular_Workers_List, Er_Workers_List, Tmp) || Tmp <- IDed_Tweets],
            1
    end.

fix_panic_msg(Tweet) ->
    Is_Not_Panic = is_atom(string:find(Tweet, "panic}", trailing)),
    if
        Is_Not_Panic ->
            handle_corrupt_tweets(Tweet);
        true ->
            Fixed_Tweet = string:replace(Tweet, "panic}", "\"panic\"}", all),
            handle_corrupt_tweets(Fixed_Tweet)
    end.

handle_corrupt_tweets(Tweet) ->
    try jsone:decode(list_to_binary([Tweet]), [{object_format, proplist}]) of
        _ -> 
            Tmp = jsone:decode(list_to_binary([Tweet]), [{object_format, proplist}]),
            Tmp
    catch
        _:_ -> 
            []
    end.

check_retweet_status(Tweet, not_found) ->
    io:format("zdorou~n"),
    [];

check_retweet_status(Tweet, <<"panic">>) ->
    [Tweet];

check_retweet_status(Tweet, Message_Info_Field) -> 
    [{<<"tweet">>, Tweet_Info_Field}, _] = Message_Info_Field,
    Is_Not_Retweet = is_atom(proplists:get_value(<<"retweeted_status">>, Tweet_Info_Field)),
    if 
        Is_Not_Retweet ->
            [Tweet_Info_Field];

        true -> 
            Retweet = proplists:get_value(<<"retweeted_status">>, Tweet_Info_Field),
            [Tweet_Info_Field, Retweet]
    end.


cast_to_workers(Index, Regular_Workers_List, Er_Workers_List, {ID, Tweet}) ->
    gen_server:cast(lists:nth(Index, Regular_Workers_List), {tweet, ID, Tweet}),
    gen_server:cast(lists:nth(Index, Er_Workers_List), {tweet, ID, Tweet}).

handle_info(Info, State) ->
    {noreply, State}.


handle_call(_,_,_) ->
    ok.