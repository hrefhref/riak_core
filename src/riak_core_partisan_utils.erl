%% -------------------------------------------------------------------
%%
%% Copyright (c) 2017 Christopher Meiklejohn.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

-module(riak_core_partisan_utils).
-author("Christopher S. Meiklejohn <christopher.meiklejohn@gmail.com>").

-export([join/1, leave/1, update/1, forward/4]).

forward(_Type, Peer, Module, Message) ->
    Manager = partisan_config:get(partisan_peer_service_manager,
                                  partisan_default_peer_service_manager),
    Manager:forward_message(Peer, Module, Message).

update(Nodes) ->
    partisan_peer_service:update_members(Nodes).

leave(Node) ->
    ok = partisan_peer_service:leave(Node).

join(Nodes) when is_list(Nodes) ->
    [join(Node) || Node <- Nodes],
    ok;
join(Node) ->
    %% Use RPC to get the node's specific IP and port binding
    %% information for the partisan backend connections.
    ListenAddrs = rpc:call(Node, partisan_config, get, [listen_addrs]),

    %% Ignore failure, partisan will retry in the background to
    %% establish connections.
    ok = partisan_peer_service:join(#{name => Node, listen_addrs => ListenAddrs}),

    ok.
