-module(test).
-export([init/0, loop/0]).

init() ->
    register(conn1, spawn(?MODULE, loop, [])).

loop() -> 
    receive
        S -> 
            io:format("~n~s~n", [S]),
            loop()
    end.