-module(client).
-define(SERVER_NODE, 'pi@192.168.2.102').
-define(PROGRAM_TO_UPDATE, 'hello').
-export([start/0,loop/0,update/0,init/0]).
-vsn(1.51).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() ->

    Pid = spawn(?MODULE,loop,[]),
	register(client,Pid).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init() ->
	{ok,{client,[C]}} = beam_lib:version(client),
	{ok,{hello,[L]}} = beam_lib:version(?PROGRAM_TO_UPDATE),
	{server,?SERVER_NODE} ! {self(), node(), beam_lib:version(?PROGRAM_TO_UPDATE), beam_lib:version(client)},
	receive
		{{ok,{hello,[V]}},{ok,{client,[Sc]}}} ->
			io:format("***CLIENT (~p)***~n", [C]),
			io:format("Hello.beam  Local: ~p Server: ~p~n",[L,V]),
			io:format("Client.beam Local: ~p Server: ~p~n",[C,Sc])
	after 
		15000 ->
			ok
	end,
	?MODULE:loop().
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	


update() ->

	code:purge(?MODULE),
	code:load_file(?MODULE).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loop() ->
    net_adm:ping(?SERVER_NODE),
	?MODULE:update(),
    {ok,{client,[C]}} = beam_lib:version(client),
	{ok,{hello,[L]}} = beam_lib:version(?PROGRAM_TO_UPDATE),
	 
	receive
		{"request_version"} ->
			{server,?SERVER_NODE} ! {self(), node(), beam_lib:version(?PROGRAM_TO_UPDATE), beam_lib:version(client)},
			receive
				{{ok,{hello,[V]}},{ok,{client,[Sc]}}} ->
					io:format("***CLIENT (~p)***~n", [C]),
					io:format("Hello.beam  Local: ~p Server: ~p~n",[L,V]),
					io:format("Client.beam Local: ~p Server: ~p~n",[C,Sc])
			after 
				5000 ->
					ok
			end
	after
		5000 ->
			ok
	end,
	?MODULE:loop().
    