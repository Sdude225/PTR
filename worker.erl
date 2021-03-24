-module(worker).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_call/3, handle_cast/2, check_tweet/2, terminate/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(Args) ->
    process_flag(trap_exit, true),
    global:register_name({regular_worker, self()}, self()),
    {ok, Args}.

handle_cast({tweet, Tweet}, State) ->
    timer:sleep(rand:uniform(451) + 49),

    check_message_type(proplists:get_value(<<"message">>, Tweet), Tweet),


    {noreply, State}.

check_message_type(<<"panic">>, _) ->
    exit(self(), kill);

check_message_type(undefined, Tweet) ->
    Language = proplists:get_value(<<"lang">>, Tweet),
    Text = proplists:get_value(<<"text">>, Tweet),
    check_tweet(binary_to_list(Language), binary_to_list(Text));

check_message_type(_, Tweet) ->
    [{<<"message">>, [{<<"tweet">>, Tweet_Info_Field}, _]}] = Tweet,

    Language = proplists:get_value(<<"lang">>, Tweet_Info_Field),
    Text = proplists:get_value(<<"text">>, Tweet_Info_Field),
    check_tweet(binary_to_list(Language), binary_to_list(Text)).

check_tweet("en", Text) ->
    Separated_Words = re:split(Text, "[ .,?!:-;/'()@]"),
    Score = [dictionary:check_word(Word) || Word <- Separated_Words],
    io:format("~nMsg: ~s~n~nScore: ~f~n/////////////////////////////////~n", [Text, lists:sum(Score)/length(Score)]);

check_tweet(_, Text) ->
    io:format("~nundefined or invalid language~nMsg: ~s~n//////////////////////////////////////~n", [Text]),
    ok.


terminate(Reason, State) ->
    % io:format("Terminating child ~p", [self()]),
    ok.


handle_call(_, _, _) ->
    ok.