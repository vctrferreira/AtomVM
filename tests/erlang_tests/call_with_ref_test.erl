%
% This file is part of AtomVM.
%
% Copyright 2018 Davide Bettio <davide@uninstall.it>
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%
% SPDX-License-Identifier: Apache-2.0 OR LGPL-2.1-or-later
%

-module(call_with_ref_test).

-export([start/0, loop/1]).

start() ->
    Pid = spawn(call_with_ref_test, loop, [initial_state()]),
    send_integer(Pid, 1),
    send_integer(Pid, 2),
    send_integer(Pid, 3),
    Value = get_integer(Pid),
    terminate(Pid),
    Value.

initial_state() ->
    [].

send_integer(Pid, Index) ->
    Ref = make_ref(),
    Pid ! {self(), Ref, put, Index},
    receive
        {Ref, ReturnCode} -> ReturnCode;
        _Any -> error
    end.

get_integer(Pid) ->
    Ref = make_ref(),
    Pid ! {self(), Ref, get},
    receive
        {Ref, Any} -> hd(Any)
    end.

terminate(Pid) ->
    Pid ! terminate.

loop(State) ->
    case handle_request(State) of
        nil ->
            ok;
        Value ->
            loop(Value)
    end.

handle_request(State) ->
    receive
        {Sender, Ref, put, Item} ->
            NextState = [Item] ++ State,
            Sender ! {Ref, ok},
            NextState;
        {Sender, Ref, get} ->
            Sender ! {Ref, State},
            State;
        terminate ->
            nil;
        _Any ->
            State
    end.
