-module(test).
-export([print/1, init/0]).


init() ->
    try Tmp = jsone:decode(<<"">>) of
        _ -> io:format("pizda")
        catch
            _:_ -> 
        end.


print(<<"hello">>) ->
    io:format("pizda nahui");

print(X) ->
    io:format("~p~n", [X*2]).