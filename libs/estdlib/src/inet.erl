%
% This file is part of AtomVM.
%
% Copyright 2018-2022 Davide Bettio <davide@uninstall.it>
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

%
% This file is part of AtomVM.
%
% Copyright 2019 Fred Dushin <fred@dushin.net>
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

-module(inet).

-export([port/1, close/1, sockname/1, peername/1]).

-type port_number() :: 0..65535.
-type socket() :: pid().
-type address() :: ipv4_address().
-type ipv4_address() :: {octet(), octet(), octet(), octet()}.
-type octet() :: 0..255.

-export_type([socket/0, port_number/0, address/0, ipv4_address/0, octet/0]).

%%-----------------------------------------------------------------------------
%% @param   Socket the socket from which to obtain the port number
%% @returns the port number associated with the local socket
%% @doc     Retrieve the actual port number to which the socket is bound.
%%          This function is useful if the port assignment is done by the
%%          operating system.
%% @end
%%-----------------------------------------------------------------------------
-spec port(Socket :: socket()) -> port_number().
port(Socket) ->
    call(Socket, {get_port}).

%%-----------------------------------------------------------------------------
%% @param   Socket the socket to close
%% @returns ok.
%% @doc     Close the socket.
%% @end
%%-----------------------------------------------------------------------------
-spec close(Socket :: socket()) -> ok.
close(Socket) ->
    call(Socket, {close}).

%%-----------------------------------------------------------------------------
%% @param   Socket the socket
%% @returns The address and port of the local end of an established connection.
%% @doc     The address and port representing the "local" end of a connection.
%%          This function should be called on a running socket instance.
%% @end
%%-----------------------------------------------------------------------------
-spec sockname(Socket :: socket()) -> {ok, {address(), port_number()}} | {error, Reason :: term()}.
sockname(Socket) ->
    call(Socket, {sockname}).

%%-----------------------------------------------------------------------------
%% @param   Socket the socket
%% @returns The address and port of the remote end of an established connection.
%% @doc     The address and port representing the "remote" end of a connection.
%%          This function should be called on a running socket instance.
%% @end
%%-----------------------------------------------------------------------------
-spec peername(Socket :: socket()) -> {ok, {address(), port_number()}} | {error, Reason :: term()}.
peername(Socket) ->
    call(Socket, {peername}).

%%
%% Internal operations
%%

%% @private
call(Socket, Msg) ->
    Ref = erlang:make_ref(),
    Socket ! {self(), Ref, Msg},
    receive
        {Ref, Ret} ->
            Ret
    end.
