%%%-------------------------------------------------------------------
%% @doc pr_lab public API
%% @end
%%%-------------------------------------------------------------------

-module(pr_lab_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    pr_lab_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
