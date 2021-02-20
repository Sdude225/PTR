-module(worker).
-behaviour(gen_server).
-export([start_link/0, init/1, handle_call/3, handle_cast/2]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init(Args) ->
    global:register_name(self(), self()),
    {ok, Args}.

handle_cast({tweet, Tweet}, State) ->
    % timer:sleep(rand:uniform(451) + 49),
    PropList = jsone:decode(list_to_binary([Tweet]), [{object_format, proplist}]),
    [{<<"message">>, [{<<"tweet">>, Tweet_Info_Field}, _]}] = PropList,

    Language = proplists:get_value(<<"lang">>, Tweet_Info_Field),
    Text = proplists:get_value(<<"text">>, Tweet_Info_Field),
    check_language(binary_to_list(Language)),
    {noreply, State}.

check_language("en") ->
    io:format("~nvalid language", []);

check_language(_) ->
    io:format("~nundefined or invalid language", []).

handle_call(_, _, _) ->
    ok.