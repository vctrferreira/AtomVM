-module(test_supervisor).

-export([test/0, init/1, start_link/0]).

test() ->
    {ok, _Pid} = start_link(),
    ok.

start_link() ->
    supervisor:start_link({local, testsup}, ?MODULE, []).

init(_Args) ->
    ChildSpecs = [
        {test_child, {ping_pong_server, start_link, []}, permanent, brutal_kill, worker, [
            ping_pong_server
        ]}
    ],
    {ok, {{one_for_one, 10000, 3600}, ChildSpecs}}.
