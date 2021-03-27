-module(worker).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_call/3, handle_cast/2, check_tweet/3, terminate/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(Args) ->
    process_flag(trap_exit, true),
    global:register_name({regular_worker, self()}, self()),
    {ok, Args}.

handle_cast({tweet, ID, Tweet}, State) ->
    timer:sleep(rand:uniform(451) + 49),

    check_message_type(proplists:get_value(<<"message">>, Tweet), Tweet, ID),
    % io:format("~n~n~nmsg ID: ~p~nworkerid: ~p~n regularworker~n~n~n", [ID, self()]),

    {noreply, State}.

check_message_type(<<"panic">>, _, _) ->
    exit(self(), kill);

check_message_type(undefined, Tweet, ID) ->
    Language = proplists:get_value(<<"lang">>, Tweet),
    Text = proplists:get_value(<<"text">>, Tweet),
    check_tweet(binary_to_list(Language), binary_to_list(Text), ID).

% check_message_type(_, Tweet, ID) ->
%     [{<<"message">>, [{<<"tweet">>, Tweet_Info_Field}, _]}] = Tweet,

%     Language = proplists:get_value(<<"lang">>, Tweet_Info_Field),
%     Text = proplists:get_value(<<"text">>, Tweet_Info_Field),
%     check_tweet(binary_to_list(Language), binary_to_list(Text), ID).

check_tweet("en", Text, ID) ->
    Separated_Words = re:split(Text, "[ .,?!:-;/'()@]"),
    Score = [dictionary:check_word(Word) || Word <- Separated_Words],
    % io:format("~n~n~n~f~n~n~n", [lists:sum(Score)/length(Score)]);
    gen_server:cast(aggregator, {emotion_value, ID, lists:sum(Score)/length(Score)});

check_tweet(_, Text, ID) ->
    gen_server:cast(aggregator, {emotion_value, ID, 0}).


terminate(Reason, State) ->
    % io:format("Terminating child ~p", [self()]),
    ok.


handle_call(_, _, _) ->
    ok.