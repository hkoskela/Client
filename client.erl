-module(client).
-define(SERVER_NODE, 'pi@192.168.2.102').
-define(PROGRAM_TO_UPDATE, 'hello').
-export([start/0,loop/0,update/0,init/0]).
-vsn(1.0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() ->

    spawn(?MODULE,init,[]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
init() ->
	{ok,{client,[C]}} = beam_lib:version(client),
	io:format("*** CLIENT (~p) *** pinging server ~p~n",[C,?SERVER_NODE]),
    case net_adm:ping(?SERVER_NODE) of
		pong ->
			?MODULE:loop();
		pang ->
			timer:sleep(10000),
			?MODULE:start()
	end.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

update() ->

	code:purge(?MODULE),
	code:load_file(?MODULE).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loop() ->

    ?MODULE:update(),
	{ok,{client,C}} = beam_lib:version(client),
	io:format("*** CLIENT (~p)*** sending version information to SERVER~n",[C]),
    
	{server,?SERVER_NODE} ! {self(), node(), beam_lib:version(?PROGRAM_TO_UPDATE)},
    receive
        {ok,{hello,[V]}} ->
			io:format("***CLIENT (~p)***~n", [C]),
			{ok,{hello,[L]}} = beam_lib:version(?PROGRAM_TO_UPDATE),
		   	io:format("Local: ~p Server: ~p~n",[L,V]);
		other ->
			io:format("~p~n",[other]),
			ok
    after
        10000 ->
            io:format("*** CLIENT (~p)*** no response~n",[C])
    end,
    timer:sleep(60000),
    ?MODULE:loop().
    
