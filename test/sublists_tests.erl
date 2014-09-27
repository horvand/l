-module(sublists_tests).
-include_lib("proper_eunit/include/pt_proper_eunit.hrl").

%% take/2
%%

take_test_() ->
    [?_assertEqual("Hello", l:take(5, "Hello, World!")),
     ?_assertEqual([1,2,3], l:take(3, [1,2,3,4,5])),
     ?_assertEqual([1,2],   l:take(3, [1,2])),
     ?_assertEqual([],      l:take(3, [])),
     ?_assertEqual([],      l:take(-1, [])),
     ?_assertEqual([],      l:take(0, [1,3])),
     ?_assertError(badarg,  l:take(foo, [1,2,3])),
     ?_assertError(badarg,  l:take(3, celestial_birds))
    ].

prop_take_identity() ->
    ?FORALL(L, list(),
            ?FORALL(N, choose(length(L), inf),
                l:take(N, L) == L)).

prop_take_as_reverse_drop() ->
    ?FORALL(L, non_empty(list()),
            ?FORALL(N, choose(0, length(L)),
                    l:take(N,L) ==
                        l:reverse(l:drop(length(L) - N,
                                         l:reverse(L))))).

%% drop/2
drop_test_() ->
    [?_assertEqual("World!", l:drop(6, "Hello World!")),
     ?_assertEqual([],       l:drop(3, [1,2])),
     ?_assertEqual([],       l:drop(3, [])),
     ?_assertEqual([1,2],    l:drop(-1, [1,2])),
     ?_assertError(badarg,   l:drop(foo, [1,2,3])),
     ?_assertError(badarg,   l:drop(7, diamonds))
    ].


%% split_at/2
split_at_test_() ->
    [?_assertEqual({"Hello ","World!"}, l:split_at(6,"Hello World!")),
     ?_assertEqual({[1,2,3],[4,5]},     l:split_at(3, [1,2,3,4,5])),
     ?_assertEqual({[1],[2,3]},         l:split_at(1, [1,2,3])),
     ?_assertEqual({[1,2,3],[]},        l:split_at(3, [1,2,3])),
     ?_assertEqual({[1,2,3],[]},        l:split_at(4, [1,2,3])),
     ?_assertEqual({[],[1,2,3]},        l:split_at(0, [1,2,3])),
     ?_assertEqual({[],[1,2,3]},        l:split_at(-1, [1,2,3])),
     ?_assertError(badarg,              l:split_at(goo, [1,2,3])),
     ?_assertError(badarg,              l:split_at(1, partridge_in_a_pear_tree))
    ].

prop_split_at_is_take_and_drop() ->
    ?FORALL(L, non_empty(list()),
            ?FORALL(N, choose(0, length(L)),
                    l:split_at(N, L) == {l:take(N,L), l:drop(N,L)})).

%% take_while/2
take_while_test_() ->
    Lt = fun(N)-> fun(X)-> X < N end end,
    [?_assertEqual([1,2],   l:take_while(Lt(3), [1,2,3,4,1,2,3,4])),
     ?_assertEqual([1,2,3], l:take_while(Lt(9), [1,2,3])),
     ?_assertEqual([],      l:take_while(Lt(0), [1,2,3])),
     ?_assertError(badarg,  l:take_while(cello, [1,2,3])),
     ?_assertError(badarg,  l:take_while(Lt(3), cliffs_of_dover))
    ].

%% drop_while/2
drop_while_test_() ->
    Lt = fun(N)-> fun(X)-> X < N end end,
    [?_assertEqual([3,4,5,1,2,3],  l:drop_while(Lt(3), [1,2,3,4,5,1,2,3])),
     ?_assertEqual([],             l:drop_while(Lt(9), [1,2,3])),
     ?_assertEqual([1,2,3],        l:drop_while(Lt(0), [1,2,3])),
     ?_assertError(badarg,         l:drop_while(eating, [1,2,3])),
     ?_assertError(badarg,         l:drop_while(Lt(1), fun()->foo end))
    ].

%% drop_while_end/2
drop_while_end_test_() ->
    IsSpace = fun(X)-> X == $  end,
    [?_assertEqual("foo",     l:drop_while_end(IsSpace, "foo ")),
     ?_assertEqual("foo bar", l:drop_while_end(IsSpace, "foo bar")),
     ?_assertError(badarg,    l:drop_while_end(black, [1,2,3])),
     ?_assertError(badarg,    l:drop_while_end(IsSpace, fun()->white end))
    ].

prop_drop_while_end() ->
    IsZero = fun(N)-> N == 0 end,
    ?FORALL(L, helpers:short_list(choose(-3,3)),
            l:drop_while_end(IsZero, L) ==
                l:reverse(l:drop_while(IsZero, l:reverse(L)))).

drop_while_end_evaluation_test() ->
    %% This verifies  the semantic check present in the
    %% `"foo\n" ++ undefined == "foo" ++ undefined` scenario.
    %% We want to inspect each value only once, and NOT reverse the list
    Sink = spawn_sink(),
    IsSpace = fun(X)-> X == $  end,
    IsSpaceEval = make_effectful_fun(Sink,IsSpace),

    ?assertThrow(eval_fail, l:drop_while_end(IsSpaceEval, "foo "++[bottom])),
    ?assertEqual([{$f, false}, {$o, false}, {$o, false},
                  {$ , true}, {throw, eval_fail}],
                 get_evaled_values(Sink)).

%% span/2

span_test_() ->
    Lt = fun(N)-> fun(X)-> X < N end end,
    [?_assertEqual({[1,2],[3,4,1,2,3,4]}, l:span(Lt(3), [1,2,3,4,1,2,3,4])),
     ?_assertEqual({[1,2,3],[]},          l:span(Lt(9), [1,2,3])),
     ?_assertEqual({[],[1,2,3]},          l:span(Lt(0), [1,2,3])),
     ?_assertError(badarg,                l:span(cpan, [1,2,3])),
     ?_assertError(badarg,                l:span(Lt(0), Lt(99)))
    ].

prop_span_is_take_while_drop_while() ->
    IsZero = fun(N)-> N == 0 end,
    ?FORALL(L, helpers:short_list(choose(-3,3)),
            l:span(IsZero, L) ==
                {l:take_while(IsZero, L), l:drop_while(IsZero, L)}).

%%% Noxious helpers live here

make_effectful_fun(SinkPid, WrappedFun) ->
    fun(bottom) ->
            SinkPid ! {evald, throw, eval_fail},
            throw(eval_fail);
       (Val) ->
            Result = WrappedFun(Val),
            SinkPid ! {evald, Val, Result},
            Result
    end.

get_evaled_values(SinkPid) ->
    SinkPid ! {dump, self()},
    receive {ok, Vs} -> Vs end.

spawn_sink() ->
    spawn_link(fun() -> loop([]) end).
loop(Acc) ->
    receive
        {dump, Caller} -> Caller ! {ok, l:reverse(Acc)};
        {evald, V, R } -> loop([{V,R}|Acc])
    end.
