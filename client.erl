-module(client).
-define(SERVER_NODE, 'pi@192.168.2.102').
-define(PROGRAM_TO_UPDATE, 'hello').
-export([start/0,loop/0,update/0]).
-vsn(1.29).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() ->

    spawn(?MODULE,loop,[]).
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
%%init() ->
%%	{ok,{client,[C]}} = beam_lib:version(client),
%%	io:format("*** CLIENT (~p) *** pinging server ~p~n",[C,?SERVER_NODE]),
%%	case net_adm:ping(?SERVER_NODE) of
%%		pong ->
%%			?MODULE:loop();
%%		pang ->
%%			timer:sleep(10000),
%%			?MODULE:start()
%%	end.
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

update() ->

	code:purge(?MODULE),
	code:load_file(?MODULE).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loop() ->

    {ok,{client,[C]}} = beam_lib:version(client),
	{ok,{hello,[L]}} = beam_lib:version(?PROGRAM_TO_UPDATE),
	io:format("*** CLIENT (~p)*** sending version information to ~p~n",[C,?SERVER_NODE]),
    
	{server,?SERVER_NODE} ! {self(), node(), beam_lib:version(?PROGRAM_TO_UPDATE), beam_lib:version(client)},
    receive
        {{ok,{hello,[V]}},{ok,{client,[Sc]}}} ->
			io:format("***CLIENT (~p)***~n", [C]),
		   	io:format("Hello.beam  Local: ~p Server: ~p~n",[L,V]),
			io:format("Client.beam Local: ~p Server: ~p~n",[C,Sc]);
		other ->
			io:format("~p~n",[other]),
			ok
    after
       15000 ->
            {server,?SERVER_NODE} ! {node(),"UpdateMe"},
			io:format("*** CLIENT (~p)*** no response~n",[C])
    end,
    ?MODULE:update(),
	timer:sleep(60000),
    ?MODULE:loop().
    
