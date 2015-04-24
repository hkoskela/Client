-module(client).
-define(SERVER_NODE, 'pi@192.168.2.102').
-define(PROGRAM_TO_UPDATE, 'hello').
-define(C_PROGRAM, '~/hello/helloc/hello_c.ver').
-export([start/0,loop/0,update/0]).
-vsn(3.05).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start() ->

    Pid = spawn(?MODULE,loop,[]),
	register(client,Pid).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

update() ->

	code:purge(?MODULE),
	code:load_file(?MODULE).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loop() ->
    ?MODULE:update(),
    {ok,{client,[C]}} = beam_lib:version(client),
	{ok,{hello,[L]}} = beam_lib:version(?PROGRAM_TO_UPDATE),
	io:format("*** CLIENT (~p)*** sending version information to ~p~n",[C,?SERVER_NODE]),
    
	case file:read_file_info(?C_PROGRAM) of
		{ok,_} -> 
			{ok,F} = file:open(?C_PROGRAM, [read]),
			{ok, Cver} = file:read_line(F),
			file:close(F),
			{server,?SERVER_NODE} ! {self(), node(), beam_lib:version(?PROGRAM_TO_UPDATE), beam_lib:version(client), Cver};
		{error,_} -> 
			Cver = '9000',
			{server,?SERVER_NODE} ! {self(), node(), beam_lib:version(?PROGRAM_TO_UPDATE), beam_lib:version(client)}
	end,
    
	receive
        {{ok,{hello,[V]}},{ok,{client,[Sc]}}} ->
			io:format("***CLIENT (~p)***~n", [C]),
		   	io:format("Hello.beam  Local: ~p Server: ~p~n",[L,V]),
			io:format("Client.beam Local: ~p Server: ~p~n",[C,Sc]);
		{{ok,{hello,[V]}},{ok,{client,[Sc]}}, Cv} ->
			io:format("***CLIENT (~p)***~n", [C]),
		   	io:format("Hello.beam  Local: ~p Server: ~p~n",[L,V]),
			io:format("Client.beam Local: ~p Server: ~p~n",[C,Sc]),
			io:format("Hello_c Local: ~p Server: ~p~n",[Cver,Cv])
	after
       15000 ->
            {server,?SERVER_NODE} ! {node(),"UpdateMe",beam_lib:version(client)},
			io:format("*** CLIENT (~p)*** no response~n",[C])
    end,
	timer:sleep(40000),
	?MODULE:loop().
    
