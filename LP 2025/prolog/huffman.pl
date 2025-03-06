% hucodec_generate_huffman_tree/2: Genera un albero di Huffman a partire da una lista di simboli e frequenze.
hucodec_generate_huffman_tree(SymbolsAndFrequencies, HuffmanTree) :-
    maplist([(Symbol, Freq), huffman_leaf(Symbol, Freq)] >> true, SymbolsAndFrequencies, Leaves),
    predsort(compare_frequencies, Leaves, SortedLeaves),
    build_huffman_tree(SortedLeaves, HuffmanTree).

compare_frequencies(Order, Node1, Node2) :-
    node_weight(Node1, Weight1),
    node_weight(Node2, Weight2),
    compare(Order, Weight1, Weight2).

node_weight(huffman_leaf(_, Weight), Weight).
node_weight(huffman_node(Weight, _, _), Weight).

build_huffman_tree([Tree], Tree).
build_huffman_tree(Leaves, HuffmanTree) :-
    [Leaf1, Leaf2 | Rest] = Leaves,
    combine_nodes(Leaf1, Leaf2, NewNode),
    insert_sorted(NewNode, Rest, NewLeaves),
    build_huffman_tree(NewLeaves, HuffmanTree).

combine_nodes(Node1, Node2, huffman_node(NewWeight, Node1, Node2)) :-
    node_weight(Node1, Weight1),
    node_weight(Node2, Weight2),
    NewWeight is Weight1 + Weight2.

insert_sorted(Node, [], [Node]).
insert_sorted(Node, [Head | Tail], [Node, Head | Tail]) :-
    node_weight(Node, Weight),
    node_weight(Head, HeadWeight),
    Weight =< HeadWeight.
insert_sorted(Node, [Head | Tail], [Head | NewTail]) :-
    node_weight(Node, Weight),
    node_weight(Head, HeadWeight),
    Weight > HeadWeight,
    insert_sorted(Node, Tail, NewTail).

% hucodec_print_huffman_tree/1: Stampa l'albero di Huffman in modo leggibile.
hucodec_print_huffman_tree(HuffmanTree) :-
    print_huffman_tree(HuffmanTree, 0).

print_huffman_tree(huffman_leaf(Symbol, Weight), IndentLevel) :-
    tab(IndentLevel),
    format("Leaf: ~w (Weight: ~w)~n", [Symbol, Weight]).

print_huffman_tree(huffman_node(Weight, Left, Right), IndentLevel) :-
    tab(IndentLevel),
    format("Internal Node (Weight: ~w)~n", [Weight]),
    NewIndent is IndentLevel + 4,
    print_huffman_tree(Left, NewIndent),
    print_huffman_tree(Right, NewIndent).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% hucodec_generate_symbol_bits_table/2: Genera una tabella di codifica (simbolo -> bits).
hucodec_generate_symbol_bits_table(HuffmanTree, SymbolBitsTable) :-
    build_symbol_bits_table(HuffmanTree, [], SymbolBitsTable).

% build_symbol_bits_table/3: Costruisce ricorsivamente la tabella di codifica.
build_symbol_bits_table(huffman_leaf(Symbol, _), CurrentBits, [(Symbol, Bits)]) :-
    reverse(CurrentBits, Bits).  % Inverti l'ordine dei bit
build_symbol_bits_table(huffman_node(_, Left, Right), CurrentBits, SymbolBitsTable) :-
    build_symbol_bits_table(Left, [0 | CurrentBits], LeftTable),
    build_symbol_bits_table(Right, [1 | CurrentBits], RightTable),
    append(LeftTable, RightTable, SymbolBitsTable).

% hucodec_encode/3: Codifica un messaggio in una lista di bit utilizzando la tabella di codifica.
hucodec_encode([], _, []).
hucodec_encode([Symbol | Rest], SymbolBitsTable, Bits) :-
    member((Symbol, SymbolBits), SymbolBitsTable),
    hucodec_encode(Rest, SymbolBitsTable, RestBits),
    append(SymbolBits, RestBits, Bits).

% Esempio di albero di Huffman:
% A = 0, B = 10, C = 11
huffman_tree(
    huffman_node(3, 
        huffman_leaf('A', 1), 
        huffman_node(2, 
            huffman_leaf('B', 1), 
            huffman_leaf('C', 1)
        )
    )
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% hucodec_decode/3: Decodifica una lista di bit utilizzando un albero di Huffman.
hucodec_decode(Bits, HuffmanTree, Message) :-
    hucodec_decode(Bits, HuffmanTree, HuffmanTree, [], Message).

% hucodec_decode/5: Funzione helper per la decodifica.
hucodec_decode([], _, _, Message, Message).
hucodec_decode([Bit | RestBits], HuffmanTree, CurrentNode, AccMessage, Message) :-
    (Bit = 0 ->
        CurrentNode = huffman_node(_, Left, _),
        NextNode = Left
    ;
        CurrentNode = huffman_node(_, _, Right),
        NextNode = Right
    ),
    (NextNode = huffman_leaf(Symbol, _) ->
        append(AccMessage, [Symbol], NewAccMessage),
        hucodec_decode(RestBits, HuffmanTree, HuffmanTree, NewAccMessage, Message)
    ;
        hucodec_decode(RestBits, HuffmanTree, NextNode, AccMessage, Message)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


