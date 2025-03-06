


## ASSEGNARE PESI
function conta_caratteri(s::String)
    # Inizializza un dizionario vuoto per contare le occorrenze
    conteggio = Dict{Char, Int}()

    # Itera su ogni carattere della stringa
    for c in s
        # Se il carattere è già nel dizionario, incrementa il conteggio
        if haskey(conteggio, c)
            conteggio[c] += 1
        else
            # Altrimenti, aggiungi il carattere al dizionario con conteggio 1
            conteggio[c] = 1
        end
    end

    # Converti il dizionario in un array di tuple (simbolo, peso)
    return [(simbolo, peso) for (simbolo, peso) in conteggio]
end


## CREAZIONE ALBERO
# Definizione della struttura di un nodo dell'albero di Huffman
struct HuffmanNode
    symbol::Union{Char, Nothing}  # Il simbolo (solo per i nodi foglia)
    weight::Int                   # Il peso del nodo (frequenza)
    left::Union{HuffmanNode, Nothing}  # Sottoalbero sinistro
    right::Union{HuffmanNode, Nothing} # Sottoalbero destro
end

# Funzione per creare un nodo foglia
function create_leaf(symbol::Char, weight::Int)
    return HuffmanNode(symbol, weight, nothing, nothing)
end

# Funzione per creare un nodo interno
function create_internal_node(left::HuffmanNode, right::HuffmanNode)
    return HuffmanNode(nothing, left.weight + right.weight, left, right)
end

# Funzione per costruire l'albero di Huffman
function hucodec_generate_huffman_tree(symbols_n_weights::Vector{Tuple{Char, Int}})
    # Creiamo una lista di nodi foglia iniziali
    nodes = [create_leaf(symbol, weight) for (symbol, weight) in symbols_n_weights]

    # Ordiniamo i nodi in base al peso (crescente)
    sort!(nodes, by = x -> x.weight)

    # Costruiamo l'albero di Huffman
    while length(nodes) > 1
        # Prendiamo i due nodi con il peso più basso
        left = popfirst!(nodes)
        right = popfirst!(nodes)

        # Creiamo un nuovo nodo interno con i due nodi come figli
        new_node = create_internal_node(left, right)

        # Inseriamo il nuovo nodo nella lista mantenendo l'ordine
        insert_sorted!(nodes, new_node)
    end

    # L'ultimo nodo rimasto è la radice dell'albero di Huffman
    return nodes[1]
end

# Funzione di supporto per inserire un nodo in una lista ordinata
function insert_sorted!(nodes::Vector{HuffmanNode}, new_node::HuffmanNode)
    index = findfirst(x -> x.weight >= new_node.weight, nodes)
    if index === nothing
        push!(nodes, new_node)
    else
        insert!(nodes, index, new_node)
    end
end

function hucodec_print_huffman_tree(node::HuffmanNode, prefix::String = "", is_last::Bool = true)
    # Stampa il nodo corrente
    if node.symbol !== nothing
        println(prefix, is_last ? "└── " : "├── ", "Leaf: ", node.symbol, " (", node.weight, ")")
    else
        println(prefix, is_last ? "└── " : "├── ", "Internal Node (", node.weight, ")")
    end

    # Aggiorna il prefisso per i figli
    new_prefix = prefix * (is_last ? "    " : "│   ")

    # Stampa il sottoalbero sinistro
    if node.left !== nothing
        hucodec_print_huffman_tree(node.left, new_prefix, node.right === nothing)
    end

    # Stampa il sottoalbero destro
    if node.right !== nothing
        hucodec_print_huffman_tree(node.right, new_prefix, true)
    end
end

function hucodec_print_huffman_tree_horizontal(node::Union{HuffmanNode, Nothing}, prefix::String = "", is_left::Bool = true)
    if node === nothing
        return
    end

    # Stampa il ramo destro (in alto)
    hucodec_print_huffman_tree_horizontal(node.right, prefix * (is_left ? "│   " : "    "), false)

    # Stampa il nodo corrente
    if node.symbol !== nothing
        println(prefix, is_left ? "└── " : "┌── ", "Leaf: ", node.symbol, " (", node.weight, ")")
    else
        println(prefix, is_left ? "└── " : "┌── ", "Internal Node (", node.weight, ")")
    end

    # Stampa il ramo sinistro (in basso)
    hucodec_print_huffman_tree_horizontal(node.left, prefix * (is_left ? "    " : "│   "), true)
end

#utilizzo
#huffman_tree = hucodec_generate_huffman_tree(symbols_n_weights)
#hucodec_print_huffman_tree_horizontal(huffman_tree)


## IMPLEM RICHIESTE
### DECODIFICA
function hucodec_decode(bits::Vector{Int}, huffman_tree::HuffmanNode)
    message = []  # Lista per memorizzare il messaggio decodificato
    current_node = huffman_tree  # Partiamo dalla radice dell'albero

    for bit in bits
        # Controlla se il bit è valido (deve essere 0 o 1)
        if bit != 0 && bit != 1
            error("Bit non valido: $bit. I bit devono essere 0 o 1.")
        end

        # Segui il percorso nell'albero in base al bit
        if bit == 0
            current_node = current_node.left
        else
            current_node = current_node.right
        end

        # Se il nodo corrente è `nothing`, i bit non corrispondono a un percorso valido
        if current_node === nothing
            error("Decodifica fallita: i bit non corrispondono a un percorso valido nell'albero di Huffman.")
        end

        # Se siamo arrivati a una foglia, aggiungi il simbolo al messaggio e ricomincia dalla radice
        if current_node.symbol !== nothing
            push!(message, current_node.symbol)
            current_node = huffman_tree  # Torna alla radice per decodificare il prossimo simbolo
        end
    end

    # Se alla fine non siamo tornati alla radice, i bit non sono stati completamente decodificati
    if current_node !== huffman_tree
        error("Decodifica fallita: i bit non sono stati completamente decodificati.")
    end

    return message
end

#=bits = [0,0,0,0,1]
m = hucodec_decode(bits, huffman_tree)
println("Messaggio decodificato: ", m)=#

### CODIFICA 
# creazione automatica albero
function hucodec_encode(message::Vector{Char})::Vector{Int}
    # Calcola le frequenze dei caratteri nel messaggio
    freq_dict = Dict{Char, Int}()
    for char in message
        freq_dict[char] = get(freq_dict, char, 0) + 1
    end

    # Crea l'albero di Huffman basato sulle frequenze
    huffman_tree = hucodec_generate_huffman_tree([(char, freq) for (char, freq) in freq_dict])

    # Codifica il messaggio utilizzando l'albero di Huffman
    return hucodec_encode(message, huffman_tree)
end

# senza albero creato automaticamente
function hucodec_encode(message::Vector{Char}, huffman_tree::HuffmanNode)::Vector{Int}
    # Genera la tabella di codifica
    symbol_bits_table = hucodec_generate_symbol_bits_table(huffman_tree)

    # Crea un dizionario per un accesso rapido
    symbol_to_bits = Dict(symbol => bits for (symbol, bits) in symbol_bits_table)

    bits = Int[]  # Lista per memorizzare i bit codificati

    for symbol in message
        # Verifica se il simbolo è presente nella tabella di codifica
        if !haskey(symbol_to_bits, symbol)
            error("Codifica fallita: il simbolo '$symbol' non è presente nell'albero di Huffman.")
        end

        # Aggiungi i bit corrispondenti al simbolo
        append!(bits, symbol_to_bits[symbol])
    end

    return bits
end

function hucodec_generate_symbol_bits_table(huffman_tree::HuffmanNode)::Vector{Tuple{Char, Vector{Int}}}
    symbol_bits_table = Dict{Char, Vector{Int}}()  # Dizionario per memorizzare la tabella
    build_symbol_bits_table(huffman_tree, Int[], symbol_bits_table)  # Costruisce la tabella

    # Converti il dizionario in un vettore di tuple (simbolo, bits)
    return [(symbol, bits) for (symbol, bits) in symbol_bits_table]
end

# Funzione di supporto per costruire la tabella di codifica (simbolo -> bits)
function build_symbol_bits_table(node::HuffmanNode, current_bits::Vector{Int}, symbol_bits_table::Dict{Char, Vector{Int}})
    if node.symbol !== nothing
        # Se è una foglia, aggiungi la codifica alla tabella
        symbol_bits_table[node.symbol] = current_bits
    else
        # Se è un nodo interno, esplora il sottoalbero sinistro e destro
        build_symbol_bits_table(node.left, [current_bits; 0], symbol_bits_table)
        build_symbol_bits_table(node.right, [current_bits; 1], symbol_bits_table)
    end
end

#= # Messaggio da codificare
message = ['C', 'a']
# Codifica
bits = hucodec_encode(message, huffman_tree)
println("Messaggio codificato: ", bits)

bits = hucodec_encode(message)
println("Messaggio codificato: ", bits)

m = hucodec_decode(bits, huffman_tree)
println("Messaggio decodificato: ", m)=#


### CODICIFICA DA FILE
function hucodec_encode_file(filename::String, huffman_tree::HuffmanNode)::Vector{Int}
    # Verifica se il file esiste
    if !isfile(filename)
        error("File non trovato: $filename")
    end
    text = ""
    # Leggi il contenuto del file
    try
        text = read(filename, String)
    catch e
        error("Errore durante la lettura del file: $e")
    end

    # Converti il testo in un array di caratteri
    char_array = collect(text)

    # Codifica il messaggio utilizzando hucodec_encode
    return hucodec_encode(char_array, huffman_tree)
end

