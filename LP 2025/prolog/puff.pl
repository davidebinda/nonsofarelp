% hucodec_encode_file/3: Codifica il contenuto di un file utilizzando un albero di Huffman.
% hucodec_encode_file(Filename, HuffmanTree, Bits)
hucodec_encode_file(Filename, HuffmanTree, Bits) :-
    % Leggi il contenuto del file
    read_file_to_chars(Filename, Chars),
    % Calcola le frequenze dei simboli
    compute_frequencies(Chars, Frequencies),
    % Genera l'albero di Huffman
    hucodec_generate_huffman_tree(Frequencies, HuffmanTree),
    % Genera la tabella di codifica
    hucodec_generate_symbol_bits_table(HuffmanTree, SymbolBitsTable),
    % Codifica il messaggio
    hucodec_encode(Chars, SymbolBitsTable, Bits).

% read_file_to_chars/2: Legge il contenuto di un file e lo converte in una lista di caratteri.
read_file_to_chars(Filename, Chars) :-
    open(Filename, read, Stream),
    read_stream_to_chars(Stream, Chars),
    close(Stream).

% read_stream_to_chars/2: Legge il contenuto di uno stream e lo converte in una lista di caratteri.
read_stream_to_chars(Stream, Chars) :-
    get_char(Stream, Char),
    (Char = end_of_file ->
        Chars = []
    ;
        Chars = [Char | RestChars],
        read_stream_to_chars(Stream, RestChars)
    ).

% compute_frequencies/2: Calcola le frequenze dei simboli in una lista.
compute_frequencies(Chars, Frequencies) :-
    compute_frequencies(Chars, [], Frequencies).

compute_frequencies([], Frequencies, Frequencies).
compute_frequencies([Char | Rest], AccFrequencies, Frequencies) :-
    (select((Char, Count), AccFrequencies, NewAccFrequencies) ->
        NewCount is Count + 1,
        compute_frequencies(Rest, [(Char, NewCount) | NewAccFrequencies], Frequencies)
    ;
        compute_frequencies(Rest, [(Char, 1) | AccFrequencies], Frequencies)
    ).

% hucodec_generate_huffman_tree/2: Genera un albero di Huffman a partire da una lista di simboli e frequenze.
hucodec_generate_huffman_tree(Frequencies, HuffmanTree) :-
    maplist([(Symbol, Freq), huffman_leaf(Symbol, Freq)] >> true, Frequencies, Leaves),
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

% hucodec_generate_symbol_bits_table/2: Genera una tabella di codifica (simbolo -> bits).
hucodec_generate_symbol_bits_table(HuffmanTree, SymbolBitsTable) :-
    build_symbol_bits_table(HuffmanTree, [], SymbolBitsTable).

build_symbol_bits_table(huffman_leaf(Symbol, _), CurrentBits, [(Symbol, Bits)]) :-
    reverse(CurrentBits, Bits).
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