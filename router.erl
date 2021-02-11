-module(router).
-export([router_main_loop/0]).



router_main_loop() ->
    receive

        {tweet, Tweet} ->
            timer:sleep(250),
            router_main_loop()
    end.